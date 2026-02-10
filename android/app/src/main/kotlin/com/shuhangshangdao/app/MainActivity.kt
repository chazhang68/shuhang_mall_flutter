package com.shuhangshangdao.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.FileProvider
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.shuhangshangdao.app/file_provider")
            .setMethodCallHandler { call, result ->
                if (call.method == "getContentUri") {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        try {
                            val file = File(filePath)
                            val uri = FileProvider.getUriForFile(
                                this,
                                "com.shuhangshangdao.app.fileprovider",
                                file
                            )
                            result.success(uri.toString())
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    } else {
                        result.error("ERROR", "filePath is null", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
