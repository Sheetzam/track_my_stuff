import 'dart:ui';
import 'dart:io';

/// Represents a detected object within a larger image.
class DetectedObject {
  const DetectedObject({
    required this.boundingBox,
    required this.imageFile,
    this.label,
    this.confidence,
  });

  final Rect boundingBox;
  final File imageFile; // The cropped image of the object
  final String? label;
  final double? confidence;
}

/// Interface for on-device object detection.
/// Abstracts dependencies like Google ML Kit.
abstract class IObjectDetectionEngine {
  /// Initialize the engine
  Future<void> init();

  /// Processes an image and returns a list of detected objects.
  /// It should also handle cropping the objects from the original image.
  Future<List<DetectedObject>> detectObjects(File imageFile);
}
