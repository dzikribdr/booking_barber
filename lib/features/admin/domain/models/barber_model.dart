class BarberModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String? phone;
  final String startTime;
  final String endTime;
  final String status;
  final DateTime? createdAt;

  BarberModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.phone,
    required this.startTime,
    required this.endTime,
    required this.status,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
