import 'dart:io';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart' as ml_kit;
import 'package:path_provider/path_provider.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

/// Implementation of [IObjectDetectionEngine] using Google ML Kit.
class MlKitObjectDetector implements IObjectDetectionEngine {
  ml_kit.ObjectDetector? _detector;

  @override
  Future<void> init() async {
    if (_detector != null) return;

    // Configure the detector for multiple object detection
    final options = ml_kit.ObjectDetectorOptions(
      mode: ml_kit.DetectionMode.single, // Use single image mode for ingestion
      classifyObjects: true,
      multipleObjects: true,
    );
    
    _detector = ml_kit.ObjectDetector(options: options);
  }

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    if (_detector == null) await init();

    final inputImage = ml_kit.InputImage.fromFile(imageFile);
    final detectedObjects = await _detector!.processImage(inputImage);
    
    final results = <DetectedObject>[];
    
    // Load the image into memory for cropping
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    
    if (originalImage == null) return [];

    final tempDir = await getTemporaryDirectory();

    for (final obj in detectedObjects) {
      final rect = obj.boundingBox;
      
      // Crop the object from the original image
      final cropped = img.copyCrop(
        originalImage,
        x: rect.left.toInt(),
        y: rect.top.toInt(),
        width: rect.width.toInt(),
        height: rect.height.toInt(),
      );
      
      // Save cropped image to a temporary file
      final fileName = 'item_${const Uuid().v4()}.jpg';
      final croppedFile = File('${tempDir.path}/$fileName');
      await croppedFile.writeAsBytes(img.encodeJpg(cropped));

      results.add(DetectedObject(
        boundingBox: rect,
        imageFile: croppedFile,
        label: obj.labels.isNotEmpty ? obj.labels.first.text : null,
        confidence: obj.labels.isNotEmpty ? obj.labels.first.confidence : null,
      ));
    }

    return results;
  }
}
