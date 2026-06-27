import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/features/items/data/ml/mock_ai_engines.dart';
import 'package:track_my_stuff/features/items/data/ml/native_embedding_engine.dart';
import 'package:track_my_stuff/features/items/data/ml/native_object_detector.dart';
import 'package:track_my_stuff/features/items/data/ml/native_vision_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Native AI Engines with MethodChannel Mocks', () {
    const channel = MethodChannel('track_my_stuff/native_ai');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'generateEmbedding':
            return List<double>.filled(384, 0.5);
          case 'generateTags':
            return ['native_tag_1', 'native_tag_2'];
          case 'detectObjects':
            return [
              {
                'x': 10.0,
                'y': 20.0,
                'width': 80.0,
                'height': 60.0,
                'imagePath': '/tmp/cropped_123.png',
                'label': 'Native Object',
                'confidence': 0.99
              }
            ];
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('NativeEmbeddingEngine generateEmbedding returns correct length', () async {
      final engine = NativeEmbeddingEngine();
      final embedding = await engine.generateEmbedding('test sentence');
      expect(embedding.length, 384);
      expect(embedding.first, 0.5);
    });

    test('NativeObjectDetector detectObjects parses native fields correctly', () async {
      final detector = NativeObjectDetector();
      final objects = await detector.detectObjects(File('test_image.png'));
      expect(objects.length, 1);
      final obj = objects.first;
      expect(obj.boundingBox.left, 10.0);
      expect(obj.boundingBox.top, 20.0);
      expect(obj.boundingBox.width, 80.0);
      expect(obj.boundingBox.height, 60.0);
      expect(obj.imageFile.path, '/tmp/cropped_123.png');
      expect(obj.label, 'Native Object');
      expect(obj.confidence, 0.99);
    });

    test('NativeVisionEngine generateTags returns list of tags', () async {
      final engine = NativeVisionEngine();
      final tags = await engine.generateTags(File('test_image.png'));
      expect(tags, ['native_tag_1', 'native_tag_2']);
    });

    test('NativeVisionEngine analyzeImage returns comma-separated string', () async {
      final engine = NativeVisionEngine();
      final description = await engine.analyzeImage(File('test_image.png'));
      expect(description, 'native_tag_1, native_tag_2');
    });
  });

  group('Mock AI Engines', () {
    test('MockEmbeddingEngine generates deterministic 384-dim vectors', () async {
      final engine = MockEmbeddingEngine();
      final vector1 = await engine.generateEmbedding('dog');
      final vector2 = await engine.generateEmbedding('dog');
      final vector3 = await engine.generateEmbedding('cat');

      expect(vector1.length, 384);
      expect(vector2.length, 384);
      expect(vector3.length, 384);

      // Deterministic check
      expect(vector1, vector2);
      // Different check
      expect(vector1, isNot(vector3));
    });

    test('MockVisionEngine generateTags returns tags based on filename', () async {
      final engine = MockVisionEngine();
      final tagsShovel = await engine.generateTags(File('/path/to/my_shovel_pic.jpg'));
      final tagsDrill = await engine.generateTags(File('/path/to/drill.jpg'));
      final tagsOther = await engine.generateTags(File('/path/to/unknown.jpg'));

      expect(tagsShovel, ['shovel', 'garden', 'tool', 'metal', 'handle']);
      expect(tagsDrill, ['drill', 'power tool', 'construction', 'hardware', 'cordless']);
      expect(tagsOther, ['item', 'household', 'object', 'storage', 'organized']);
    });

    test('MockObjectDetector returns full bounds of original file', () async {
      final detector = MockObjectDetector();
      final File testFile = File('dummy.jpg');
      final objects = await detector.detectObjects(testFile);

      expect(objects.length, 1);
      expect(objects.first.imageFile.path, testFile.path);
      expect(objects.first.boundingBox.width, 100.0);
    });
  });
}
