class StyleVaultModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String imageUrl;
  final String? notes;
  final DateTime? createdAt;

  StyleVaultModel({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.imageUrl,
    this.notes,
    this.createdAt,
  });

  factory StyleVaultModel.fromJson(Map<String, dynamic> json) {
    return StyleVaultModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bookingId: json['booking_id'],
      imageUrl: json['image_url'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'booking_id': bookingId,
      'image_url': imageUrl,
      'notes': notes,
    };
  }
}
