import 'dart:io';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:uuid/uuid.dart';

/// Mock implementation of [IObjectDetectionEngine].
/// Treats the whole image as a single detected object.
/// Used on iOS Simulator where ML Kit binaries are incompatible.
class MockObjectDetector implements IObjectDetectionEngine {
  @override
  Future<void> init() async {
    // No-op for mock
  }

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? originalImage;
    try {
      originalImage = img.decodeImage(bytes);
    } catch (_) {
      return [];
    }
    if (originalImage == null) return [];

    final tempDir = await getTemporaryDirectory();
    final rect = Rect.fromLTWH(
        0, 0, originalImage.width.toDouble(), originalImage.height.toDouble());

    final cropped = img.copyCrop(
      originalImage,
      x: 0,
      y: 0,
      width: originalImage.width,
      height: originalImage.height,
    );

    final croppedFile =
        File('${tempDir.path}/item_${const Uuid().v4()}.jpg');
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));

    return [
      DetectedObject(
        boundingBox: rect,
        imageFile: croppedFile,
        label: 'Object',
        confidence: 1,
      ),
    ];
  }
}
