import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:track_my_stuff/features/items/data/ml/tflite_embedding_engine.dart';

import 'tflite_embedding_engine_test.mocks.dart';

@GenerateMocks([Interpreter])
void main() {
  late TfliteEmbeddingEngine engine;
  late MockInterpreter mockInterpreter;

  setUp(() {
    mockInterpreter = MockInterpreter();
    engine = TfliteEmbeddingEngine(interpreter: mockInterpreter);
  });

  group('TfliteEmbeddingEngine', () {
    test('should generate an embedding of correct length', () async {
      // Mock the run method to fill the output with dummy data
      when(mockInterpreter.run(any, any)).thenAnswer((invocation) {
        final output = invocation.positionalArguments[1] as List;
        for (var i = 0; i < 384; i++) {
          output[0][i] = 0.5;
        }
      });

      final embedding = await engine.generateEmbedding('test text');
      expect(embedding.length, 384);
      expect(embedding.first, 0.5);
    });
  });
}
