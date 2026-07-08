package com.tabibsoft.tabib_soft_company

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
  private val channelName = "tabib_soft_company/file_opener"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
      if (call.method == "openFile") {
        val path = call.argument<String>("path")
        val mimeType = call.argument<String>("mimeType") ?: "*/*"
        if (path == null) {
          result.error("PATH_MISSING", "File path is required.", null)
          return@setMethodCallHandler
        }

        val file = File(path)
        if (!file.exists()) {
          result.error("FILE_NOT_FOUND", "File does not exist: $path", null)
          return@setMethodCallHandler
        }

        val contentUri: Uri = FileProvider.getUriForFile(
          this,
          "${applicationContext.packageName}.fileprovider",
          file,
        )

        val intent = Intent(Intent.ACTION_VIEW).apply {
          setDataAndType(contentUri, mimeType)
          addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
          addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        if (intent.resolveActivity(packageManager) != null) {
          startActivity(intent)
          result.success(true)
        } else {
          result.success(false)
        }
      } else {
        result.notImplemented()
      }
    }
  }
}
