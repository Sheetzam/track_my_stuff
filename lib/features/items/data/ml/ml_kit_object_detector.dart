import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'
    as ml_kit;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:uuid/uuid.dart';

/// True when running on the iOS Simulator (not a physical device).
/// SIMULATOR_DEVICE_NAME is set by Xcode only in simulator processes.
bool get _isIosSimulator =>
    Platform.isIOS &&
    Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');

/// True when real ML Kit detection should be used.
/// Android always uses ML Kit. iOS uses it only on physical devices.
bool get _useMlKit => Platform.isAndroid || (Platform.isIOS && !_isIosSimulator);

/// Implementation of [IObjectDetectionEngine] using Google ML Kit.
/// Falls back to a mock (whole-image crop) on the iOS Simulator due to
/// the arm64-simulator binary incompatibility with ML Kit.
class MlKitObjectDetector implements IObjectDetectionEngine {
  ml_kit.ObjectDetector? _detector;

  @override
  Future<void> init() async {
    if (!_useMlKit || _detector != null) return;
    final options = ml_kit.ObjectDetectorOptions(
      mode: ml_kit.DetectionMode.single,
      classifyObjects: true,
      multipleObjects: true,
    );
    _detector = ml_kit.ObjectDetector(options: options);
  }

  @override
  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    if (_useMlKit) {
      return _detectWithMlKit(imageFile);
    }
    return _mockDetect(imageFile);
  }

  Future<List<DetectedObject>> _detectWithMlKit(File imageFile) async {
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
      final w =
          rect.width.clamp(1, originalImage.width - x).toInt();
      final h =
          rect.height.clamp(1, originalImage.height - y).toInt();

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

  /// Mock path: treats the whole image as a single detected object.
  /// Used on iOS Simulator where ML Kit binaries are incompatible.
  Future<List<DetectedObject>> _mockDetect(File imageFile) async {
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
