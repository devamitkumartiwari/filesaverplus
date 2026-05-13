package com.amit.filesaverplus

import android.Manifest
import android.app.Activity
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class FilesaverplusPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingCall: MethodCall? = null
    private var pendingResult: MethodChannel.Result? = null
    private val requestCode = 39285

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "filesaverplus")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${Build.VERSION.RELEASE}")
            }

            "getBatteryPercentage" -> {
                val bm = context.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
                val level = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                if (level == null || level == -1) {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                } else {
                    result.success(level)
                }
            }

            "saveMultipleFiles" -> {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q &&
                    ContextCompat.checkSelfPermission(
                        context, Manifest.permission.WRITE_EXTERNAL_STORAGE
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    activity?.let {
                        pendingCall = call
                        pendingResult = result
                        ActivityCompat.requestPermissions(
                            it,
                            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                            requestCode
                        )
                    } ?: result.error("ACTIVITY_NOT_ATTACHED", "Activity is null", null)
                } else {
                    handleSaveFiles(call, result)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun handleSaveFiles(call: MethodCall, result: MethodChannel.Result) {
        val dataList: List<ByteArray>? = call.argument("dataList")
        val fileNameList: List<String>? = call.argument("fileNameList")
        val mimeTypeList: List<String>? = call.argument("mimeTypeList")

        if (dataList == null || fileNameList == null || mimeTypeList == null) {
            result.error("INVALID_ARGUMENTS", "Missing arguments", null)
            return
        }

        val savedPaths = mutableListOf<String>()

        for (i in dataList.indices) {
            val data = dataList[i]
            val fileName = fileNameList[i]
            val mimeType = mimeTypeList[i]

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val resolver = context.contentResolver
                val contentValues = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                    put(MediaStore.Downloads.MIME_TYPE, mimeType)
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }

                val uri = resolver.insert(
                    MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
                    contentValues
                )

                if (uri != null) {
                    resolver.openFileDescriptor(uri, "w")?.use { pfd ->
                        FileOutputStream(pfd.fileDescriptor).use { fos ->
                            fos.write(data)
                        }
                    }
                    contentValues.clear()
                    contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
                    resolver.update(uri, contentValues, null, null)
                    savedPaths.add(uri.toString())
                } else {
                    result.error(
                        "WRITE_FAILED",
                        "Failed to insert into MediaStore for $fileName",
                        null
                    )
                    return
                }
            } else {
                val downloadsDir =
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val file = File(downloadsDir, fileName)
                FileOutputStream(file).use { fos -> fos.write(data) }
                savedPaths.add(file.absolutePath)
            }
        }

        result.success(savedPaths)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener { code, _, grantResults ->
            if (code == requestCode) {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    pendingCall?.let { call ->
                        pendingResult?.let { res -> handleSaveFiles(call, res) }
                    }
                } else {
                    pendingResult?.error("PERMISSION_DENIED", "Write permission not granted", null)
                }
                pendingCall = null
                pendingResult = null
                true
            } else {
                false
            }
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}
