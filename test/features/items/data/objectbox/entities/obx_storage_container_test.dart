import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_stuff/features/items/data/objectbox/entities/obx_storage_container.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';

void main() {
  group('ObxStorageContainer mapping tests', () {
    test('ObxStorageContainer fromDomain and toDomain round-trip maps all fields correctly (without parentId)', () {
      final now = DateTime.now();
      final originalContainer = StorageContainer(
        id: 'container-123',
        name: 'Kitchen Box',
        description: 'Pots and pans',
        imageUrl: 'assets/kitchen.jpg',
        createdAt: now,
      );

      // Convert Domain -> Obx entity
      final entity = ObxStorageContainer.fromDomain(originalContainer);

      // Verify entity fields
      expect(entity.domainId, originalContainer.id);
      expect(entity.name, originalContainer.name);
      expect(entity.description, originalContainer.description);
      expect(entity.imageUrl, originalContainer.imageUrl);
      expect(entity.createdAt, originalContainer.createdAt);
      expect(entity.parentId, null);

      // Convert Obx entity -> Domain
      final mappedContainer = entity.toDomain();

      // Verify domain fields match original
      expect(mappedContainer.id, originalContainer.id);
      expect(mappedContainer.name, originalContainer.name);
      expect(mappedContainer.description, originalContainer.description);
      expect(mappedContainer.imageUrl, originalContainer.imageUrl);
      expect(mappedContainer.createdAt, originalContainer.createdAt);
      expect(mappedContainer.parentId, null);
    });

    test('ObxStorageContainer maps parentId correctly', () {
      final now = DateTime.now();
      final originalContainer = StorageContainer(
        id: 'container-nested',
        name: 'Spices Box',
        description: 'Seasoning and herbs',
        imageUrl: 'assets/spices.jpg',
        createdAt: now,
        parentId: 'container-parent-123',
      );

      // Convert Domain -> Obx entity
      final entity = ObxStorageContainer.fromDomain(originalContainer);
      expect(entity.parentId, 'container-parent-123');

      // Convert Obx entity -> Domain
      final mappedContainer = entity.toDomain();
      expect(mappedContainer.parentId, 'container-parent-123');
    });
  });
}
