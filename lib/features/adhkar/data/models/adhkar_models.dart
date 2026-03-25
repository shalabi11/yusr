class AdhkarItem {
  final int id;
  final String text;
  final int count;

  const AdhkarItem({required this.id, required this.text, required this.count});

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'] as int? ?? 0,
      text: json['text']?.toString() ?? '',
      count: json['count'] as int? ?? 1,
    );
  }
}

class AdhkarCategory {
  final int id;
  final String category;
  final List<AdhkarItem> items;

  const AdhkarCategory({
    required this.id,
    required this.category,
    required this.items,
  });

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    final array = (json['array'] as List<dynamic>? ?? const []);
    return AdhkarCategory(
      id: json['id'] as int? ?? 0,
      category: json['category']?.toString() ?? '',
      items: array
          .map((e) => AdhkarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
