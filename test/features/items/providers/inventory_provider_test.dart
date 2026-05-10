import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/core/interfaces/embedding_engine_interface.dart';
import 'package:track_my_stuff/core/interfaces/local_database_interface.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';
import 'package:track_my_stuff/features/items/providers/inventory_provider.dart';

// --- FAKES ---
class FakeLocalDatabase implements ILocalDatabase {
  final List<Item> _items = [];
  final List<StorageContainer> _containers = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> saveContainer(StorageContainer container) async {
    _containers.add(container);
  }

  @override
  Future<List<StorageContainer>> getAllContainers() async => _containers;

  @override
  Future<StorageContainer?> getContainer(String id) async => 
      _containers.where((c) => c.id == id).firstOrNull;

  @override
  Future<void> deleteContainer(String id) async {
    _containers.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> saveItem(Item item, {List<double>? embedding}) async {
    _items.add(item);
  }

  @override
  Future<List<Item>> getItemsInContainer(String containerId) async =>
      _items.where((i) => i.containerId == containerId).toList();

  @override
  Future<Item?> getItem(String id) async =>
      _items.where((i) => i.id == id).firstOrNull;

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<List<Item>> searchItemsByVector(List<double> vectorEmbedding, {int? limit}) async {
    return _items.take(limit ?? 10).toList();
  }
}

class FakeEmbeddingEngine implements IEmbeddingEngine {
  @override
  Future<void> init() async {}

  @override
  Future<List<double>> generateEmbedding(String text) async {
    return [0.1, 0.2, 0.3]; 
  }
}

// --- TESTS ---
void main() {
  group('InventoryProvider Tests', () {
    test('adding an item successfully saves it to the local database', () async {
      // 1. Setup the container with mocked interfaces
      final fakeDb = FakeLocalDatabase();
      final container = ProviderContainer(
        overrides: [
          localDatabaseProvider.overrideWith((ref) => fakeDb),
          embeddingEngineProvider.overrideWith((ref) => FakeEmbeddingEngine()),
        ],
      );
      addTearDown(container.dispose);

      final inventoryController = container.read(inventoryProvider.notifier);
      
      // 2. Create a test item
      final date = DateTime(2026);
      final item = Item(
        id: 'test-item-1',
        containerId: 'box-1',
        name: 'Hammer',
        description: 'A heavy hammer',
        imageUrl: '/path.png',
        createdAt: date,
      );

      // 3. Add the item
      await inventoryController.addItem(item);
      
      // 4. Verify it was added by querying the DB
      final itemsInBox = await inventoryController.getItemsForContainer('box-1');
      expect(itemsInBox.length, 1);
      expect(itemsInBox.first.name, 'Hammer');
    });
  });
}
