import 'package:objectbox/objectbox.dart';
import 'package:track_my_stuff/features/items/domain/storage_container.dart';

/// Database-specific Entity for a Storage Container.
/// This acts as a bridge between ObjectBox and our Domain model.
@Entity()
class ObxStorageContainer {
  ObxStorageContainer({
    required this.domainId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    this.obxId = 0,
    this.parentId,
  });

  /// Map from Domain Model -> ObjectBox Entity
  factory ObxStorageContainer.fromDomain(StorageContainer container) {
    return ObxStorageContainer(
      domainId: container.id,
      name: container.name,
      description: container.description,
      imageUrl: container.imageUrl,
      createdAt: container.createdAt,
      parentId: container.parentId,
    );
  }

  @Id()
  int obxId = 0; // ObjectBox requires integer IDs

  @Unique()
  String domainId; // This maps to our pure Domain model's String ID

  String name;
  String description;
  String imageUrl;
  String? parentId;
  
  @Property(type: PropertyType.date)
  DateTime createdAt;

  /// Map from ObjectBox Entity -> Domain Model
  StorageContainer toDomain() {
    return StorageContainer(
      id: domainId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      parentId: parentId,
      createdAt: createdAt,
    );
  }
}
