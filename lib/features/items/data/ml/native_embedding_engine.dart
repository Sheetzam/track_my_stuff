import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/features/items/data/ml/native_ai_client.dart';

/// Concrete implementation of [IEmbeddingEngine] using platform-native APIs (AICore/CoreML).
class NativeEmbeddingEngine implements IEmbeddingEngine {
  final NativeAiClient _client;

  NativeEmbeddingEngine({NativeAiClient? client}) : _client = client ?? NativeAiClient();

  @override
  Future<void> init() async {
    // Platform channels do not require explicit model loading initialization on the Dart side.
  }

  @override
  Future<List<double>> generateEmbedding(String text) async {
    return _client.generateEmbedding(text);
  }
}
