import 'dart:io';
import 'package:track_my_stuff/core/interfaces/vision_llm_interface.dart';
import 'package:track_my_stuff/features/items/data/ml/native_ai_client.dart';

/// Concrete implementation of [IVisionLLMEngine] using platform-native APIs (AICore/Apple Intelligence).
class NativeVisionEngine implements IVisionLLMEngine {
  final NativeAiClient _client;

  NativeVisionEngine({NativeAiClient? client}) : _client = client ?? NativeAiClient();

  @override
  Future<void> init() async {
    // Platform channels do not require explicit model loading initialization on the Dart side.
  }

  @override
  Future<String> analyzeImage(File imageFile, {String prompt = "Describe this item in a few words for inventory tracking."}) async {
    final tags = await generateTags(imageFile);
    return tags.join(', ');
  }

  @override
  Future<List<String>> generateTags(File imageFile) async {
    return _client.generateTags(imageFile.path);
  }
}
