import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:track_my_stuff/features/items/data/ml/tflite_embedding_engine.dart';
import 'package:track_my_stuff/features/items/data/ml/wordpiece_tokenizer.dart';

import 'tflite_embedding_engine_test.mocks.dart';

@GenerateMocks([Interpreter])
void main() {
  late MockInterpreter mockInterpreter;
  late WordPieceTokenizer tokenizer;

  setUp(() {
    mockInterpreter = MockInterpreter();
    when(mockInterpreter.run(any, any)).thenAnswer((invocation) {
      final output = invocation.positionalArguments[1] as List;
      for (var i = 0; i < 384; i++) {
        output[0][i] = 0.5;
      }
    });

    // Create a minimal vocabulary for testing
    tokenizer = WordPieceTokenizer();
    tokenizer.loadVocabularyFromString(
      '[PAD]\n[UNK]\n[CLS]\n[SEP]\nhello\nworld\ntest\ntext\nskip\ninit\n##s\n',
    );
  });

  group('TfliteEmbeddingEngine', () {
    test('returns embedding of correct length', () async {
      final engine = TfliteEmbeddingEngine(
        interpreter: mockInterpreter,
        tokenizer: tokenizer,
      );
      final embedding = await engine.generateEmbedding('test text');
      expect(embedding.length, 384);
      expect(embedding.first, 0.5);
    });

    test('passes input of shape [1, 128] to interpreter', () async {
      final engine = TfliteEmbeddingEngine(
        interpreter: mockInterpreter,
        tokenizer: tokenizer,
      );
      await engine.generateEmbedding('hello');

      final captured = verify(mockInterpreter.run(captureAny, any)).captured;
      final input = captured.first as List<List<int>>;
      expect(input.length, 1);
      expect(input[0].length, 128);
    });

    test('skips init() if interpreter and tokenizer already provided', () async {
      final engine = TfliteEmbeddingEngine(
        interpreter: mockInterpreter,
        tokenizer: tokenizer,
      );
      // generateEmbedding should not throw even without asset loading
      await engine.generateEmbedding('skip init');
      // If init() were called it would try to load assets and fail in test env
      verifyNever(mockInterpreter.close());
    });
  });
}
