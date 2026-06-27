import 'dart:io';
import 'dart:ui';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:track_my_stuff/features/items/data/ml/native_ai_client.dart';

/// Concrete implementation of [IObjectDetectionEngine] using platform-native APIs (Vision/ML Kit).
class NativeObjectDetector implements IObjectDetectionEngine {
  final NativeAiClient _client;

  NativeObjectDetector({NativeAiClient? client}) : _client = client ?? NativeAiClient();

  @override
  Future<void> init() async {
    // Platform channels do not require explicit model loading initialization on the Dart side.
  }

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    final results = await _client.detectObjects(imageFile.path);
    return results.map((map) {
      final x = (map['x'] as num).toDouble();
      final y = (map['y'] as num).toDouble();
      final width = (map['width'] as num).toDouble();
      final height = (map['height'] as num).toDouble();
      final cropPath = map['imagePath'] as String;
      final label = map['label'] as String?;
      final confidence = (map['confidence'] as num?)?.toDouble();

      return DetectedObject(
        boundingBox: Rect.fromLTWH(x, y, width, height),
        imageFile: File(cropPath),
        label: label,
        confidence: confidence,
      );
    }).toList();
  }
}
