package com.example.kleiderschrank_app

import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "kleiderschrank/pose"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "detectPose" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("ARG", "path missing", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val bmp = BitmapFactory.decodeFile(path)
                            if (bmp == null) {
                                result.error("IMG", "cannot decode image", null)
                                return@setMethodCallHandler
                            }

                            val keypoints = PoseLandmarkerWrapper.detect(applicationContext, bmp)
                            result.success(keypoints)
                        } catch (e: Exception) {
                            result.error("POSE", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
