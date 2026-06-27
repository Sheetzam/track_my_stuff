import 'package:flutter/services.dart';

/// Client to communicate with native platform-specific AI APIs (AICore and Apple Intelligence/CoreML)
/// using MethodChannel.
class NativeAiClient {
  static const MethodChannel _channel = MethodChannel('track_my_stuff/native_ai');

  /// Generate a semantic embedding vector from text
  Future<List<double>> generateEmbedding(String text) async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod<List<dynamic>>(
        'generateEmbedding',
        {'text': text},
      );
      if (result == null) return [];
      return result.cast<double>();
    } catch (e) {
      print('Error generating native embedding: $e');
      rethrow;
    }
  }

  /// Generate descriptive tags for an image file
  Future<List<String>> generateTags(String imagePath) async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod<List<dynamic>>(
        'generateTags',
        {'imagePath': imagePath},
      );
      if (result == null) return [];
      return result.cast<String>();
    } catch (e) {
      print('Error generating native tags: $e');
      rethrow;
    }
  }

  /// Detect salient objects/regions in an image
  Future<List<Map<String, dynamic>>> detectObjects(String imagePath) async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod<List<dynamic>>(
        'detectObjects',
        {'imagePath': imagePath},
      );
      if (result == null) return [];
      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('Error detecting native objects: $e');
      rethrow;
    }
  }
}
