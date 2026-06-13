import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/features/items/data/objectbox/entities/obx_item.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';

void main() {
  group('ObxItem mapping tests', () {
    test('ObxItem fromDomain and toDomain round-trip maps all fields including vector/embedding', () {
      final now = DateTime.now();
      final originalItem = Item(
        id: 'test-item-123',
        containerId: 'box-abc',
        name: 'Screwdriver',
        description: 'Phillips head screwdriver',
        imageUrl: 'assets/screwdriver.png',
        createdAt: now,
        vector: [0.1, 0.2, 0.3, 0.4],
      );

      // Convert Domain -> Obx entity
      final entity = ObxItem.fromDomain(originalItem, embedding: originalItem.vector);

      // Verify entity fields
      expect(entity.domainId, originalItem.id);
      expect(entity.containerId, originalItem.containerId);
      expect(entity.name, originalItem.name);
      expect(entity.description, originalItem.description);
      expect(entity.imageUrl, originalItem.imageUrl);
      expect(entity.createdAt, originalItem.createdAt);
      expect(entity.embedding, originalItem.vector);

      // Convert Obx entity -> Domain
      final mappedItem = entity.toDomain();

      // Verify domain fields match original, including vector/embedding
      expect(mappedItem.id, originalItem.id);
      expect(mappedItem.containerId, originalItem.containerId);
      expect(mappedItem.name, originalItem.name);
      expect(mappedItem.description, originalItem.description);
      expect(mappedItem.imageUrl, originalItem.imageUrl);
      expect(mappedItem.createdAt, originalItem.createdAt);
      expect(mappedItem.vector, originalItem.vector);
    });
  });
}
