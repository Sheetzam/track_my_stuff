import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';

void main() {
  group('Domain Models Test', () {
    test('StorageContainer serialization works correctly', () {
      final date = DateTime(2026);
      final container = StorageContainer(
        id: 'box-1',
        name: 'Winter Clothes',
        description: 'Coats and scarves',
        imageUrl: '/local/path/img.png',
        createdAt: date,
      );

      final json = container.toMap();
      expect(json['id'], 'box-1');
      expect(json['parentId'], null);

      final fromJson = StorageContainer.fromMap(json);
      expect(fromJson.id, container.id);
      expect(fromJson.name, container.name);
      expect(fromJson.createdAt, container.createdAt);
    });

    test('Item serialization works correctly', () {
      final date = DateTime(2026);
      final item = Item(
        id: 'item-1',
        containerId: 'box-1',
        name: 'Red Scarf',
        description: 'Wool scarf with tassels',
        imageUrl: '/local/path/scarf.png',
        createdAt: date,
      );

      final json = item.toMap();
      expect(json['id'], 'item-1');
      expect(json['containerId'], 'box-1');

      final fromJson = Item.fromMap(json);
      expect(fromJson.id, item.id);
      expect(fromJson.name, item.name);
      expect(fromJson.createdAt, item.createdAt);
    });
  });
}
