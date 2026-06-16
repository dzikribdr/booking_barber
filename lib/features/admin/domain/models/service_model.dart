class ServiceModel {
  final String id;
  final String name;
  final String? description;
  final int durationMinutes;
  final double price;
  final DateTime? createdAt;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      durationMinutes: json['duration_minutes'] ?? 30,
      price: (json['price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'duration_minutes': durationMinutes,
      'price': price,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    int? durationMinutes,
    double? price,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
