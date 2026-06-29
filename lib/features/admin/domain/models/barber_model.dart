class BarberModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String? phone;
  final String startTime;
  final String endTime;
  final String status;
  final double rating;
  final int reviewsCount;
  final DateTime? createdAt;

  BarberModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.phone,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.createdAt,
  });

  factory BarberModel.fromJson(Map<String, dynamic> json) {
    return BarberModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo_url'],
      phone: json['phone'],
      startTime: json['start_time'] ?? '09:00:00',
      endTime: json['end_time'] ?? '21:00:00',
      status: json['status'] ?? 'active',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'photo_url': photoUrl,
      'phone': phone,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'rating': rating,
      'reviews_count': reviewsCount,
    };
  }

  BarberModel copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? phone,
    String? startTime,
    String? endTime,
    String? status,
    double? rating,
    int? reviewsCount,
    DateTime? createdAt,
  }) {
    return BarberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
