import 'package:objectbox/objectbox.dart';
import 'package:track_my_stuff/features/items/domain/item.dart';

/// Database-specific Entity for an Item.
/// Includes the Vector Search indexing required by ObjectBox.
@Entity()
class ObxItem {
  ObxItem({
    required this.domainId,
    required this.containerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    this.obxId = 0,
    this.embedding,
  });

  /// Map from Domain Model -> ObjectBox Entity
  factory ObxItem.fromDomain(Item item, {List<double>? embedding}) {
    return ObxItem(
      domainId: item.id,
      containerId: item.containerId,
      name: item.name,
      description: item.description,
      imageUrl: item.imageUrl,
      createdAt: item.createdAt,
      embedding: embedding,
    );
  }

  @Id()
  int obxId = 0;

  @Unique()
  String domainId;

  String containerId;
  String name;
  String description;
  String imageUrl;

  // HNSW Vector Index for Semantic Search 
  // We specify 384 dimensions because we will use the lightweight MiniLM model for embeddings.
  @HnswIndex(dimensions: 384)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  /// Map from ObjectBox Entity -> Domain Model
  Item toDomain() {
    return Item(
      id: domainId,
      containerId: containerId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
