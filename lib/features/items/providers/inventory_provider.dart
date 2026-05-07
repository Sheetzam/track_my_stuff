import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';

part 'inventory_provider.g.dart';

/// Provider for the local database interface.
/// In the main.dart file, we will override this with our ObjectBox implementation.
@riverpod
ILocalDatabase localDatabase(Ref ref) {
  throw UnimplementedError('Must be overridden in main() with ObjectBox implementation');
}

/// Provider for the embedding engine interface.
/// In the main.dart file, we will override this with our TFLite implementation.
@riverpod
IEmbeddingEngine embeddingEngine(Ref ref) {
  throw UnimplementedError('Must be overridden in main() with TFLite implementation');
}

/// The main controller for managing inventory items.
/// It uses the abstract interfaces, ensuring it never touches ObjectBox or TFLite directly.
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
    // Set state to loading while we perform the database operation
    state = const AsyncLoading();
    
    // Perform the operation and catch any errors safely into the AsyncValue state
    state = await AsyncValue.guard(() async {
      final db = ref.read(localDatabaseProvider);
      await db.saveItem(item);
    });
  }

  Future<List<Item>> getItemsForContainer(String containerId) {
    final db = ref.read(localDatabaseProvider);
    return db.getItemsInContainer(containerId);
  }
}
