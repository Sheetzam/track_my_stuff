import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:track_my_stuff/features/items/data/ml/local_vision_engine.dart';

import 'local_vision_engine_test.mocks.dart';

@GenerateMocks([Llama])
void main() {
  group('LocalVisionEngine', () {
    test('skips init() if Llama already provided', () async {
      final mockLlama = MockLlama();
      // If init() were called it would try to load assets and fail in test env.
      // Constructing with a pre-built Llama instance must not trigger init().
      LocalVisionEngine(llama: mockLlama);

      // Verify no asset-loading methods were called on the mock
      verifyZeroInteractions(mockLlama);
    });
  });
}
