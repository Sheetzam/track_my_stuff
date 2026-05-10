import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/core/interfaces/object_detection_interface.dart';
import 'package:track_my_stuff/core/interfaces/vision_llm_interface.dart';
import 'package:track_my_stuff/features/items/data/ml/local_vision_engine.dart';
import 'package:track_my_stuff/features/items/data/ml/ml_kit_object_detector.dart';
import 'package:track_my_stuff/features/items/data/ml/mock_object_detector.dart';
import 'package:track_my_stuff/features/items/data/ml/tflite_embedding_engine.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';

part 'inventory_provider.g.dart';

/// Provider for the local database interface.
/// Must be overridden in main() with an initialized ObjectBoxRepository.
@riverpod
ILocalDatabase localDatabase(Ref ref) {
  throw UnimplementedError('Must be overridden in main()');
}

/// Provider for the embedding engine interface.
@riverpod
IEmbeddingEngine embeddingEngine(Ref ref) => TfliteEmbeddingEngine();

/// Whether ML Kit is available (controlled by --dart-define=USE_MLKIT=true/false).
/// Defaults to true. Set to false for iOS Simulator builds (dev flavor).
const _useMlKit = bool.fromEnvironment('USE_MLKIT', defaultValue: true);

/// Provider for the object detection interface.
/// Uses ML Kit on Android/physical iOS, mock on iOS Simulator (dev flavor).
@riverpod
IObjectDetectionEngine objectDetectionEngine(Ref ref) =>
    _useMlKit ? MlKitObjectDetector() : MockObjectDetector();

/// Provider for the vision LLM interface.
@riverpod
IVisionLLMEngine visionLLMEngine(Ref ref) => LocalVisionEngine();

/// The main controller for managing inventory items.
@riverpod
class Inventory extends _$Inventory {
  @override
  FutureOr<void> build() {
    // Initial state is just empty/ready
  }

  Future<void> addContainer(StorageContainer container) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(localDatabaseProvider);
      await db.saveContainer(container);
    });
  }

  Future<void> addItem(Item item) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(localDatabaseProvider);
      await db.saveItem(item);
    });
  }

  Future<List<Item>> getItemsForContainer(String containerId) {
    final db = ref.read(localDatabaseProvider);
    return db.getItemsInContainer(containerId);
  }

  Future<List<Item>> searchItems(String query) async {
    final embeddingEng = ref.read(embeddingEngineProvider);
    final db = ref.read(localDatabaseProvider);
    
    final vector = await embeddingEng.generateEmbedding(query);
    return db.searchItemsByVector(vector);
  }
}
