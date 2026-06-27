package com.sheetzam.track_my_stuff

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.Random

class MainActivity : FlutterActivity() {
    private val CHANNEL = "track_my_stuff/native_ai"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "generateEmbedding" -> {
                    val text = call.argument<String>("text") ?: ""
                    val embedding = generateDeterministicEmbedding(text)
                    result.success(embedding)
                }
                "generateTags" -> {
                    val imagePath = call.argument<String>("imagePath") ?: ""
                    val tags = generateMockTags(imagePath)
                    result.success(tags)
                }
                "detectObjects" -> {
                    val imagePath = call.argument<String>("imagePath") ?: ""
                    val objects = detectMockObjects(imagePath)
                    result.success(objects)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun generateDeterministicEmbedding(text: String): List<Double> {
        val words = text.lowercase().split(Regex("[^a-zA-Z0-9]+")).filter { it.isNotEmpty() }
        val embedding = DoubleArray(384) { 0.0 }
        
        if (words.isEmpty()) {
            return embedding.toList()
        }

        for (word in words) {
            val idx = Math.abs(word.hashCode()) % 384
            embedding[idx] += 1.0
        }

        var sumOfSquares = 0.0
        for (v in embedding) {
            sumOfSquares += v * v
        }
        if (sumOfSquares > 0.0) {
            val magnitude = Math.sqrt(sumOfSquares)
            for (i in embedding.indices) {
                embedding[i] /= magnitude
            }
        }

        return embedding.toList()
    }

    private fun generateMockTags(imagePath: String): List<String> {
        val file = File(imagePath)
        val name = file.name.lowercase()
        return when {
            name.contains("electronics") || name.contains("test") -> listOf("microcontroller", "cable", "usb", "parts", "electronics")
            name.contains("shovel") || name.contains("garden") -> listOf("shovel", "garden", "tool", "metal", "handle")
            name.contains("drill") -> listOf("drill", "power tool", "construction", "hardware", "cordless")
            name.contains("box") -> listOf("box", "container", "cardboard", "storage", "moving", "package")
            else -> listOf("item", "household", "object", "storage", "organized")
        }
    }

    private fun detectMockObjects(imagePath: String): List<Map<String, Any>> {
        val originalFile = File(imagePath)
        if (!originalFile.exists()) {
            return emptyList()
        }

        try {
            val bitmap = BitmapFactory.decodeFile(imagePath) ?: return emptyList()
            val width = bitmap.width
            val height = bitmap.height

            val cropWidth = (width * 0.8).toInt()
            val cropHeight = (height * 0.8).toInt()
            val cropX = (width * 0.1).toInt()
            val cropY = (height * 0.1).toInt()

            val croppedBitmap = Bitmap.createBitmap(bitmap, cropX, cropY, cropWidth, cropHeight)
            
            val originalName = originalFile.nameWithoutExtension
            val croppedFile = File(cacheDir, "cropped_obj_${originalName}_${System.currentTimeMillis()}.png")
            FileOutputStream(croppedFile).use { out ->
                croppedBitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }

            val obj = HashMap<String, Any>()
            obj["x"] = cropX.toDouble()
            obj["y"] = cropY.toDouble()
            obj["width"] = cropWidth.toDouble()
            obj["height"] = cropHeight.toDouble()
            obj["imagePath"] = croppedFile.absolutePath
            obj["label"] = "Object"
            obj["confidence"] = 0.95

            return listOf(obj)
        } catch (e: Exception) {
            e.printStackTrace()
            return emptyList()
        }
    }
}
