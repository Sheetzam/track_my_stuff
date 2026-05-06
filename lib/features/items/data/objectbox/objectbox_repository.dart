import 'package:path_provider/path_provider.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/features/items/data/objectbox/entities/obx_item.dart';
import 'package:track_my_stuff/features/items/data/objectbox/entities/obx_storage_container.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/objectbox.g.dart';

/// The concrete implementation of our local database using ObjectBox.
class ObjectBoxRepository implements ILocalDatabase {
  late final Store _store;
  late final Box<ObxStorageContainer> _containerBox;
  late final Box<ObxItem> _itemBox;

  @override
  Future<void> init() async {
    // ObjectBox requires knowing where on the device to store the physical file
    final docsDir = await getApplicationDocumentsDirectory();
    _store = await openStore(directory: '${docsDir.path}/track_my_stuff_db');
    
    _containerBox = _store.box<ObxStorageContainer>();
    _itemBox = _store.box<ObxItem>();
  }

  @override
  Future<void> saveContainer(StorageContainer container) async {
    // Check if it already exists to preserve the internal ObjectBox integer ID
    final query = _containerBox.query(ObxStorageContainer_.domainId.equals(container.id)).build();
    final existing = query.findFirst();
    query.close();

    final obxContainer = ObxStorageContainer.fromDomain(container);
    if (existing != null) {
      obxContainer.obxId = existing.obxId;
    }
    
    _containerBox.put(obxContainer);
  }

  @override
  Future<List<StorageContainer>> getAllContainers() async {
    final all = _containerBox.getAll();
    return all.map((obx) => obx.toDomain()).toList();
  }

  @override
  Future<StorageContainer?> getContainer(String id) async {
    final query = _containerBox.query(ObxStorageContainer_.domainId.equals(id)).build();
    final result = query.findFirst();
    query.close();
    return result?.toDomain();
  }

  @override
  Future<void> deleteContainer(String id) async {
    final query = _containerBox.query(ObxStorageContainer_.domainId.equals(id)).build();
    final existing = query.findFirst();
    query.close();
    if (existing != null) {
      _containerBox.remove(existing.obxId);
    }
  }

  @override
  Future<void> saveItem(Item item) async {
    final query = _itemBox.query(ObxItem_.domainId.equals(item.id)).build();
    final existing = query.findFirst();
    query.close();

    // Preserve the embedding if it already exists, as the pure domain model doesn't hold the embedding vector yet
    final obxItem = ObxItem.fromDomain(item, embedding: existing?.embedding);
    if (existing != null) {
      obxItem.obxId = existing.obxId;
    }
    
    _itemBox.put(obxItem);
  }

  @override
  Future<List<Item>> getItemsInContainer(String containerId) async {
    final query = _itemBox.query(ObxItem_.containerId.equals(containerId)).build();
    final all = query.find();
    query.close();
    return all.map((obx) => obx.toDomain()).toList();
  }

  @override
  Future<Item?> getItem(String id) async {
    final query = _itemBox.query(ObxItem_.domainId.equals(id)).build();
    final result = query.findFirst();
    query.close();
    return result?.toDomain();
  }

  @override
  Future<void> deleteItem(String id) async {
    final query = _itemBox.query(ObxItem_.domainId.equals(id)).build();
    final existing = query.findFirst();
    query.close();
    if (existing != null) {
      _itemBox.remove(existing.obxId);
    }
  }

  @override
  Future<List<Item>> searchItemsByVector(List<double> vectorEmbedding, {int limit = 10}) async {
    // This is the magic of ObjectBox: native C++ level Vector Similarity Search
    final query = _itemBox.query(ObxItem_.embedding.nearestNeighborsF32(vectorEmbedding, limit)).build();
    final results = query.find();
    query.close();
    return results.map((obx) => obx.toDomain()).toList();
  }
}
