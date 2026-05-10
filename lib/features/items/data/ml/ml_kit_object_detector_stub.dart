import 'dart:io';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';

/// Stub implementation of MlKitObjectDetector for when the
/// google_mlkit_object_detection package is not available (iOS Simulator builds).
/// This class is never actually instantiated — the provider uses MockObjectDetector
/// when USE_MLKIT=false. It exists only to satisfy the Dart compiler.
class MlKitObjectDetector implements IObjectDetectionEngine {
  @override
  Future<void> init() async {
    throw UnsupportedError('ML Kit is not available in this build');
  }

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    throw UnsupportedError('ML Kit is not available in this build');
  }
}
