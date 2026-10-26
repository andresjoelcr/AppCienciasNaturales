package com.example.mi_app

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import com.xraph.plugin.flutter_unity_widget.FlutterUnityActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterUnityActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.mi_app/marcador_download"
        ).setMethodCallHandler { call, result ->
            if (call.method != "savePdf") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            try {
                val fileName = call.argument<String>("fileName")
                    ?: throw IllegalArgumentException("Falta el nombre del archivo")
                val bytes = call.argument<ByteArray>("bytes")
                    ?: throw IllegalArgumentException("Faltan los datos del PDF")
                val resolver = applicationContext.contentResolver
                val values = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                    put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                        put(MediaStore.Downloads.IS_PENDING, 1)
                    }
                }
                val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                    ?: throw IllegalStateException("No se pudo crear el archivo")
                resolver.openOutputStream(uri)?.use { it.write(bytes) }
                    ?: throw IllegalStateException("No se pudo guardar el archivo")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val completed = ContentValues().apply {
                        put(MediaStore.Downloads.IS_PENDING, 0)
                    }
                    resolver.update(uri, completed, null, null)
                }
                result.success(true)
            } catch (error: Exception) {
                result.error("DOWNLOAD_FAILED", error.message, null)
            }
        }
    }
}
