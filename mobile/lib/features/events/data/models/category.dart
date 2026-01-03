class Category {
  final String id;
  final String name;
  final String colorHex;
  final int priorityLevel;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    this.priorityLevel = 5,
    this.isDefault = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['color_hex'] as String,
      priorityLevel: json['priority_level'] as int? ?? 5,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
