class CustomerProfileModel {
  final String userId;
  final int trustScore;
  final bool isSilentMode;
  final String? defaultPaymentMethod;

  CustomerProfileModel({
    required this.userId,
    this.trustScore = 100,
    this.isSilentMode = false,
    this.defaultPaymentMethod,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      userId: json['user_id'] ?? '',
      trustScore: json['trust_score'] ?? 100,
      isSilentMode: json['is_silent_mode'] ?? false,
      defaultPaymentMethod: json['default_payment_method'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'trust_score': trustScore,
      'is_silent_mode': isSilentMode,
      'default_payment_method': defaultPaymentMethod,
    };
  }

  CustomerProfileModel copyWith({
    String? userId,
    int? trustScore,
    bool? isSilentMode,
    String? defaultPaymentMethod,
  }) {
    return CustomerProfileModel(
      userId: userId ?? this.userId,
      trustScore: trustScore ?? this.trustScore,
      isSilentMode: isSilentMode ?? this.isSilentMode,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
    );
  }
}
