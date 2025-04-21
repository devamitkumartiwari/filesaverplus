package com.amit.filesaverplus

import android.app.Activity
import android.content.ContentValues
import android.content.Context
import android.os.BatteryManager
import android.os.Build
import android.os.ParcelFileDescriptor
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.io.FileOutputStream

class FilesaverplusPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var context: Context
  private var currentActivity: Activity? = null
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "filesaverplus")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${Build.VERSION.RELEASE}")
      }
      "getBatteryPercentage" -> {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val percentage = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        result.success(percentage)
      }
      "saveMultipleFiles" -> {
        val dataList: List<ByteArray>? = call.argument("dataList")
        val fileNameList: List<String>? = call.argument("fileNameList")
        val mimeTypeList: List<String>? = call.argument("mimeTypeList")

        if (dataList != null && fileNameList != null && mimeTypeList != null) {
          saveMultipleFiles(dataList, fileNameList, mimeTypeList)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENTS", "Missing file data", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun saveMultipleFiles(dataList: List<ByteArray>, fileNameList: List<String>, mimeTypeList: List<String>) {
    val resolver = context.contentResolver
    val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)

    for (i in dataList.indices) {
      val fileName = fileNameList[i]
      val mimeType = mimeTypeList[i]
      val data = dataList[i]

      val values = ContentValues().apply {
        put(MediaStore.Downloads.DISPLAY_NAME, fileName)
        put(MediaStore.Downloads.MIME_TYPE, mimeType)
        put(MediaStore.Downloads.IS_PENDING, 1)
      }

      val itemUri = resolver.insert(collection, values)

      itemUri?.let {
        resolver.openFileDescriptor(it, "w")?.use { pfd ->
          FileOutputStream(pfd.fileDescriptor).use { fos ->
            fos.write(data)
          }
        }

        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        resolver.update(it, values, null, null)
      } ?: Log.e("FilesaverplusPlugin", "Failed to insert file: $fileName")
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    currentActivity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    currentActivity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    currentActivity = binding.activity
  }

  override fun onDetachedFromActivity() {
    currentActivity = null
  }
}
