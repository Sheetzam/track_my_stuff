import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'
    as ml_kit;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:uuid/uuid.dart';

/// Implementation of [IObjectDetectionEngine] using Google ML Kit.
/// Only used on platforms where ML Kit is available (Android, physical iOS).
/// For iOS Simulator, use [MockObjectDetector] instead.
class MlKitObjectDetector implements IObjectDetectionEngine {
  ml_kit.ObjectDetector? _detector;

  @override
  Future<void> init() async {
    if (_detector != null) return;
    final options = ml_kit.ObjectDetectorOptions(
      mode: ml_kit.DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    _detector = ml_kit.ObjectDetector(options: options);
  }

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    if (_detector == null) await init();

    final inputImage = ml_kit.InputImage.fromFile(imageFile);
    final mlObjects = await _detector!.processImage(inputImage);

    if (mlObjects.isEmpty) return [];

    final bytes = await imageFile.readAsBytes();
    img.Image? originalImage;
    try {
      originalImage = img.decodeImage(bytes);
    } catch (_) {
      return [];
    }
    if (originalImage == null) return [];

    final tempDir = await getTemporaryDirectory();
    final results = <DetectedObject>[];

    for (final mlObj in mlObjects) {
      final rect = mlObj.boundingBox;
      final label = mlObj.labels.isNotEmpty ? mlObj.labels.first.text : null;
      final confidence =
          mlObj.labels.isNotEmpty ? mlObj.labels.first.confidence : null;

      // Clamp bounding box to image bounds
      final x = rect.left.clamp(0, originalImage.width - 1).toInt();
      final y = rect.top.clamp(0, originalImage.height - 1).toInt();
      final w = rect.width.clamp(1, originalImage.width - x).toInt();
      final h = rect.height.clamp(1, originalImage.height - y).toInt();

      final cropped = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: w,
        height: h,
      );

      final croppedFile =
          File('${tempDir.path}/item_${const Uuid().v4()}.jpg');
      await croppedFile.writeAsBytes(img.encodeJpg(cropped));

      results.add(DetectedObject(
        boundingBox: Rect.fromLTWH(
            rect.left, rect.top, rect.width, rect.height),
        imageFile: croppedFile,
        label: label,
        confidence: confidence,
      ));
    }

    return results;
  }
}
