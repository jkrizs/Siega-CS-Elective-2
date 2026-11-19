class Category {
  final int id;
  final String name;
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {'name': name};
}

