/// This interface dictates how the application generates semantic embeddings from text.
/// The app will depend on this interface, allowing us to swap TFLite for a different
/// ML package if a better one is released in the future.
abstract class IEmbeddingEngine {
  /// Initialize the ML model (load into memory)
  Future<void> init();
  
  /// Takes a text string and returns a mathematical vector embedding
  Future<List<double>> generateEmbedding(String text);
}
