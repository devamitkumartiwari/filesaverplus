package com.therivanta.filesaverplus

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Saves files without declaring or requesting any permission.
 *
 * - Android 10+ (API 29+): writes into the public Downloads collection through
 *   MediaStore, which needs no permission for files the app creates.
 * - Android 7–9 (API 24–28): writes into the app-specific Downloads folder
 *   (`Android/data/<package>/files/Download`), which needs no permission either.
 */
class FilesaverplusPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var executor: ExecutorService? = null
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
        executor = Executors.newSingleThreadExecutor()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        executor?.shutdown()
        executor = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "getBatteryPercentage" -> getBatteryPercentage(result)
            "saveMultipleFiles" -> saveMultipleFiles(call, result)
            else -> result.notImplemented()
        }
    }

    // region Battery

    private fun getBatteryPercentage(result: MethodChannel.Result) {
        val bm = context.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
        val level = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        if (level == null || level < 0 || level == Int.MIN_VALUE) {
            result.error("UNAVAILABLE", "Battery level not available.", null)
        } else {
            result.success(level)
        }
    }

    // endregion

    // region Save

    private fun saveMultipleFiles(call: MethodCall, result: MethodChannel.Result) {
        val dataList: List<ByteArray>? = call.argument("dataList")
        val fileNameList: List<String>? = call.argument("fileNameList")
        val mimeTypeList: List<String>? = call.argument("mimeTypeList")

        if (dataList == null || fileNameList == null || mimeTypeList == null) {
            result.error(
                "INVALID_ARGUMENTS",
                "Expected dataList, fileNameList and mimeTypeList.",
                null
            )
            return
        }
        if (dataList.size != fileNameList.size || dataList.size != mimeTypeList.size) {
            result.error(
                "INVALID_ARGUMENTS",
                "dataList, fileNameList and mimeTypeList must have the same length.",
                null
            )
            return
        }

        val worker = executor
        if (worker == null || worker.isShutdown) {
            result.error("WRITE_FAILED", "Plugin is detached from the engine.", null)
            return
        }

        // Disk I/O runs off the UI thread; the result is delivered on the main thread.
        worker.execute {
            val saved = ArrayList<String>(dataList.size)
            for (i in dataList.indices) {
                val fileName = sanitizeFileName(fileNameList[i])
                try {
                    saved.add(saveOne(dataList[i], fileName, mimeTypeList[i]))
                } catch (e: Exception) {
                    mainHandler.post {
                        result.error(
                            "WRITE_FAILED",
                            "Failed to save '$fileName': ${e.message ?: e.javaClass.simpleName}",
                            saved.toList()
                        )
                    }
                    return@execute
                }
            }
            mainHandler.post { result.success(saved) }
        }
    }

    private fun saveOne(data: ByteArray, fileName: String, mimeType: String): String =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveToMediaStoreDownloads(data, fileName, mimeType)
        } else {
            saveToAppDownloads(data, fileName)
        }

    /** API 29+: public Downloads via MediaStore. No permission required. */
    private fun saveToMediaStoreDownloads(data: ByteArray, fileName: String, mimeType: String): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            throw IllegalStateException("MediaStore.Downloads requires API 29")
        }
        val resolver = context.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri: Uri = resolver.insert(collection, values)
            ?: throw IOException("MediaStore refused to create an entry")

        try {
            val stream = resolver.openOutputStream(uri)
                ?: throw IOException("Could not open an output stream")
            stream.use { it.write(data) }

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } catch (e: Exception) {
            // Don't leave a half-written, pending row behind.
            try {
                resolver.delete(uri, null, null)
            } catch (_: Exception) {
            }
            throw e
        }
        return uri.toString()
    }

    /** API 24–28: app-specific Downloads folder. No permission required. */
    private fun saveToAppDownloads(data: ByteArray, fileName: String): String {
        val dir = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
            ?: File(context.filesDir, "Download")
        if (!dir.exists() && !dir.mkdirs()) {
            throw IOException("Could not create ${dir.absolutePath}")
        }
        val file = uniqueFile(dir, fileName)
        FileOutputStream(file).use { it.write(data) }
        return file.absolutePath
    }

    // endregion

    companion object {
        private const val CHANNEL = "filesaverplus"
        private val ILLEGAL_CHARS = Regex("[\\\\/:*?\"<>|\\x00-\\x1F\\x7F]")

        /** Replaces characters that are illegal in file names; never returns an empty name. */
        internal fun sanitizeFileName(name: String): String {
            val cleaned = name.replace(ILLEGAL_CHARS, "_").trim().trim('.').trim()
            return cleaned.ifEmpty { "file" }
        }

        /** Returns `dir/name`, or `dir/name (1).ext`, `dir/name (2).ext`, ... if taken. */
        internal fun uniqueFile(dir: File, name: String): File {
            var file = File(dir, name)
            if (!file.exists()) return file
            val dot = name.lastIndexOf('.')
            val base = if (dot > 0) name.substring(0, dot) else name
            val ext = if (dot > 0) name.substring(dot) else ""
            var n = 1
            while (file.exists()) {
                file = File(dir, "$base ($n)$ext")
                n++
            }
            return file
        }
    }
}
