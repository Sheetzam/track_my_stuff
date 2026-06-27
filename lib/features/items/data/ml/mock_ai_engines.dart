import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:track_my_stuff/core/interfaces/vision_llm_interface.dart';

/// Mock implementation of [IEmbeddingEngine] returning deterministic 384-dim mock vectors.
class MockEmbeddingEngine implements IEmbeddingEngine {
  @override
  Future<void> init() async {}

  @override
  Future<List<double>> generateEmbedding(String text) async {
    final words = text.toLowerCase().split(RegExp(r'[^a-zA-Z0-9]+')).where((w) => w.isNotEmpty);
    final List<double> result = List<double>.filled(384, 0.0);
    
    if (words.isEmpty) {
      return result;
    }

    for (final word in words) {
      final idx = word.hashCode.abs() % 384;
      result[idx] += 1.0;
    }

    var sumOfSquares = 0.0;
    for (final val in result) {
      sumOfSquares += val * val;
    }

    if (sumOfSquares > 0.0) {
      final magnitude = sqrt(sumOfSquares);
      for (var i = 0; i < 384; i++) {
        result[i] /= magnitude;
      }
    }

    return result;
  }
}

/// Mock implementation of [IVisionLLMEngine] returning tags based on filename.
class MockVisionEngine implements IVisionLLMEngine {
  @override
  Future<void> init() async {}

  @override
  Future<String> analyzeImage(File imageFile, {String prompt = ""}) async {
    final tags = await generateTags(imageFile);
    return tags.join(', ');
  }

  @override
  Future<List<String>> generateTags(File imageFile) async {
    final name = imageFile.path.toLowerCase();
    if (name.contains('electronics') || name.contains('test')) {
      return ['microcontroller', 'cable', 'usb', 'parts', 'electronics'];
    } else if (name.contains('shovel') || name.contains('garden')) {
      return ['shovel', 'garden', 'tool', 'metal', 'handle'];
    } else if (name.contains('drill')) {
      return ['drill', 'power tool', 'construction', 'hardware', 'cordless'];
    } else if (name.contains('box')) {
      return ['box', 'container', 'cardboard', 'storage', 'moving', 'package'];
    } else {
      return ['item', 'household', 'object', 'storage', 'organized'];
    }
  }
}

/// Mock implementation of [IObjectDetectionEngine] returning a simulated cropped object.
class MockObjectDetector implements IObjectDetectionEngine {
  @override
  Future<void> init() async {}

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    // Simply returns the whole image (or simulated cropped area) as a single detected object
    return [
      DetectedObject(
        boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
        imageFile: imageFile,
        label: 'Object',
        confidence: 0.95,
      ),
    ];
  }
}
