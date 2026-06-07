class ServiceItem {
  final String id;
  final String category;
  final String name;
  final String description;
  final int durationMinutes;
  final double price;

  ServiceItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.price,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}
