import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';

/// This interface dictates how the application interacts with the local database.
/// The rest of the app will depend on this interface, NEVER the underlying database package.
/// This allows us to swap SQLite for ObjectBox (or anything else) later with zero UI changes.
abstract class ILocalDatabase {
  /// Initialize the database connection
  Future<void> init();
  
  // --- Containers ---
  Future<void> saveContainer(StorageContainer container);
  Future<List<StorageContainer>> getAllContainers();
  Future<StorageContainer?> getContainer(String id);
  Future<void> deleteContainer(String id);
  
  // --- Items ---
  Future<void> saveItem(Item item);
  Future<List<Item>> getItemsInContainer(String containerId);
  Future<Item?> getItem(String id);
  Future<void> deleteItem(String id);
  
  // --- Search ---
  /// Performs a semantic vector similarity search
  Future<List<Item>> searchItemsByVector(List<double> vectorEmbedding, {int limit = 10});
}
