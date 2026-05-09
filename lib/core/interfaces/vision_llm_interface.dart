import 'dart:io';

/// Interface for on-device Local Vision LLM.
/// Used to generate descriptive tags and descriptions for items.
abstract class IVisionLLMEngine {
  /// Initialize the model (load GGUF or other weights into memory)
  Future<void> init();

  /// Analyzes an image and returns a list of suggested tags or a description.
  Future<String> analyzeImage(File imageFile, {String prompt = "Describe this item in a few words for inventory tracking."});
  
  /// Generates tags specifically for the item
  Future<List<String>> generateTags(File imageFile);
}
