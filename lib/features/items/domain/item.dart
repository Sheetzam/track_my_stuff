class Item {
  const Item({
    required this.id,
    required this.containerId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      containerId: map['containerId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  final String id;
  final String containerId;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'containerId': containerId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Item copyWith({
    String? id,
    String? containerId,
    String? name,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      containerId: containerId ?? this.containerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
