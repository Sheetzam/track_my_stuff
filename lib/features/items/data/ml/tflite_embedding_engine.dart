import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/features/items/data/ml/wordpiece_tokenizer.dart';

/// Concrete implementation of [IEmbeddingEngine] using TensorFlow Lite.
/// Uses the all-MiniLM-L6-v2 model with proper WordPiece tokenization.
class TfliteEmbeddingEngine implements IEmbeddingEngine {
  Interpreter? _interpreter;
  final WordPieceTokenizer _tokenizer;

  TfliteEmbeddingEngine({Interpreter? interpreter, WordPieceTokenizer? tokenizer})
      : _interpreter = interpreter,
        _tokenizer = tokenizer ?? WordPieceTokenizer();

  @override
  Future<void> init() async {
    if (_interpreter != null && _tokenizer.isInitialized) return;

    try {
      // Load the TFLite model
      _interpreter ??= await Interpreter.fromAsset('assets/models/minilm_l6_v2.tflite');

      // Load the WordPiece vocabulary
      if (!_tokenizer.isInitialized) {
        await _tokenizer.loadVocabulary('assets/models/vocab.txt');
      }
    } catch (e) {
      print('Error initializing TFLite Embedding Engine: $e');
      rethrow;
    }
  }

  @override
  Future<List<double>> generateEmbedding(String text) async {
    if (_interpreter == null || !_tokenizer.isInitialized) {
      await init();
    }

    // Tokenize with proper WordPiece algorithm
    final tokenIds = _tokenizer.tokenize(text);

    // MiniLM-L6-v2 expects input shape [1, 128] (batch of 1, sequence length 128)
    final input = [tokenIds];

    // Output shape [1, 384] (batch of 1, 384-dimensional embedding)
    final output = List<double>.filled(384, 0).reshape([1, 384]);

    // Run inference
    _interpreter!.run(input, output);

    // Flatten and return
    return List<double>.from(output[0] as Iterable);
  }
}
