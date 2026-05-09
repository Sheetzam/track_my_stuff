import 'dart:io';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:track_my_stuff/core/interfaces/vision_llm_interface.dart';

/// Implementation of [IVisionLLMEngine] using llama_cpp_dart.
/// Supports multimodal models like Moondream2 or LLaVA.
class LocalVisionEngine implements IVisionLLMEngine {
  Llama? _llama;

  @override
  Future<void> init() async {
    if (_llama != null) return;

    try {
      // 1. Copy assets to local filesystem (llama_cpp needs direct file paths)
      final modelPath = await _copyAssetToFile('assets/models/vision_model.gguf');
      final mmprojPath = await _copyAssetToFile('assets/models/vision_mmproj.gguf');

      // 2. Initialize Llama
      // In version 0.1.2, parameters are passed via cascades or specific setters
      _llama = Llama(
        modelPath,
        mmprojPath: mmprojPath,
        contextParams: ContextParams()..nCtx = 2048,
        modelParams: ModelParams()..nGpuLayers = 99,
      );
    } catch (e) {
      print('Error initializing Local Vision Engine: $e');
      rethrow;
    }
  }

  @override
  Future<String> analyzeImage(File imageFile, {String prompt = "Describe this item in a few words for inventory tracking."}) async {
    if (_llama == null) await init();

    final response = StringBuffer();
    
    // In 0.1.2, generateWithMedia is the way to handle multimodal input
    final stream = _llama!.generateWithMedia(
      "<IMAGE>\nUser: $prompt\nAssistant:", // Moondream prompt format
      images: [imageFile.path], // Some versions take paths, some take LlamaImage
    );

    await for (final token in stream) {
      response.write(token);
    }

    return response.toString().trim();
  }

  @override
  Future<List<String>> generateTags(File imageFile) async {
    final description = await analyzeImage(
      imageFile, 
      prompt: "Generate a comma-separated list of 5 keywords describing this item. Output ONLY the keywords.",
    );
    
    return description.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<String> _copyAssetToFile(String assetPath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final fileName = assetPath.split('/').last;
    final localFile = File('${docsDir.path}/$fileName');

    if (!await localFile.exists()) {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await localFile.writeAsBytes(bytes);
    }

    return localFile.path;
  }
}
