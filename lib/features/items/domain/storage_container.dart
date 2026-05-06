class StorageContainer {
  const StorageContainer({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    this.parentId,
  });

  factory StorageContainer.fromMap(Map<String, dynamic> map) {
    return StorageContainer(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      parentId: map['parentId'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String? parentId;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  StorageContainer copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    String? parentId,
  }) {
    return StorageContainer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
    );
  }
}
