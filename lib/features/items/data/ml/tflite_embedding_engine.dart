import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';

/// Concrete implementation of [IEmbeddingEngine] using TensorFlow Lite.
/// This implementation uses the all-MiniLM-L6-v2 model.
class TfliteEmbeddingEngine implements IEmbeddingEngine {
  Interpreter? _interpreter;

  @override
  Future<void> init() async {
    if (_interpreter != null) return;
    
    try {
      // Load the model from assets
      _interpreter = await Interpreter.fromAsset('assets/models/minilm_l6_v2.tflite');
      
      // Log model details for debugging
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();
      
      print('TFLite Model Loaded:');
      print('Input Tensors: $inputTensors');
      print('Output Tensors: $outputTensors');
    } catch (e) {
      print('Error loading TFLite model: $e');
      rethrow;
    }
  }

  @override
  Future<List<double>> generateEmbedding(String text) async {
    if (_interpreter == null) {
      await init();
    }

    // --- Tokenization (CRITICAL STEP) ---
    // MiniLM-L6-v2 expects a tensor of token IDs.
    // For a production app, we would use a proper WordPiece tokenizer.
    // For this MVP implementation, we'll start with a basic character-based 
    // or simple word-based placeholder until we integrate a full tokenizer.
    // 
    // NOTE: all-MiniLM-L6-v2 usually takes [1, 128] int32 input.
    final input = _preprocess(text);
    
    // Prepare output buffer (384 dimensions for MiniLM-L6-v2)
    final output = List<double>.filled(384, 0).reshape([1, 384]);

    // Run inference
    _interpreter!.run(input, output);

    // Flatten and return the result
    return List<double>.from(output[0] as Iterable);
  }

  /// Placeholder preprocessing/tokenization logic.
  /// In a real implementation, this would involve a Vocabulary lookup.
  List<List<int>> _preprocess(String text) {
    // MiniLM usually expects a max sequence length (e.g., 128)
    const maxLen = 128;
    final tokens = List<int>.filled(maxLen, 0);
    
    // Very naive tokenization: just taking char codes for now as a placeholder
    // to verify the TFLite tensor plumbing.
    final chars = text.codeUnits;
    for (var i = 0; i < chars.length && i < maxLen; i++) {
      tokens[i] = chars[i];
    }
    
    return [tokens];
  }
}
