import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:track_my_stuff/core/interfaces/vision_llm_interface.dart';
import 'package:track_my_stuff/features/items/data/ml/native_embedding_engine.dart';
import 'package:track_my_stuff/features/items/data/ml/native_object_detector.dart';
import 'package:track_my_stuff/features/items/data/ml/native_vision_engine.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';

void main() {
  group('Engine providers construct lazily without main.dart overrides', () {
    test('embeddingEngineProvider returns a NativeEmbeddingEngine', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final engine = container.read(embeddingEngineProvider);
      expect(engine, isA<IEmbeddingEngine>());
      expect(engine, isA<NativeEmbeddingEngine>());
    });

    test('objectDetectionEngineProvider returns a NativeObjectDetector', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final engine = container.read(objectDetectionEngineProvider);
      expect(engine, isA<IObjectDetectionEngine>());
      expect(engine, isA<NativeObjectDetector>());
    });

    test('visionLLMEngineProvider returns a NativeVisionEngine', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final engine = container.read(visionLLMEngineProvider);
      expect(engine, isA<IVisionLLMEngine>());
      expect(engine, isA<NativeVisionEngine>());
    });
  });
}
