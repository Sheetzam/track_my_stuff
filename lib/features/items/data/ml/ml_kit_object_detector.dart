import 'dart:io';
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart' as ml_kit;
import 'package:path_provider/path_provider.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'dart:ui';

/// Implementation of [IObjectDetectionEngine] using Google ML Kit.
/// Note: Real implementation is currently disabled for iOS Simulator compatibility.
class MlKitObjectDetector implements IObjectDetectionEngine {
  // ml_kit.ObjectDetector? _detector;

  @override
  Future<void> init() async {
    // if (_detector != null) return;
    // ...
  }

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    // if (_detector == null) await init();
    
    // Mock implementation for development/simulator
    final results = <DetectedObject>[];
    
    // Load the image into memory for cropping
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    
    if (originalImage == null) return [];

    final tempDir = await getTemporaryDirectory();

    // Just "detect" the whole image as a single object for now
    final rect = Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble());
    
    // Crop the object (it's the whole image)
    final cropped = img.copyCrop(
      originalImage,
      x: 0,
      y: 0,
      width: originalImage.width,
      height: originalImage.height,
    );
    
    // Save cropped image to a temporary file
    final fileName = 'item_${const Uuid().v4()}.jpg';
    final croppedFile = File('${tempDir.path}/$fileName');
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));

    results.add(DetectedObject(
      boundingBox: rect,
      imageFile: croppedFile,
      label: "Object",
      confidence: 1.0,
    ));

    return results;
  }
}
