import 'barber_model.dart';
import 'service_model.dart';

class BookingModel {
  final String id;
  final String? userId;
  final String? barberId;
  final String? serviceId;
  final DateTime bookingDate;
  final String status;
  final double? totalPrice;
  final DateTime? createdAt;
  final String? customerName;
  final String? walkInName;
  final DateTime? endTime;
  final bool isForOther;
  final String? guestName;
  
  // Relations
  final BarberModel? barber;
  final ServiceModel? service;

  BookingModel({
    required this.id,
    this.userId,
    this.barberId,
    this.serviceId,
    required this.bookingDate,
    required this.status,
    this.totalPrice,
    this.createdAt,
    this.customerName,
    this.walkInName,
    this.endTime,
    this.isForOther = false,
    this.guestName,
    this.barber,
    this.service,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['customer_id'],
      barberId: json['barber_id'],
      serviceId: json['service_id'],
      bookingDate: (json['booking_time'] ?? json['booking_date']) != null 
          ? DateTime.parse(json['booking_time'] ?? json['booking_date']) 
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      totalPrice: json['total_price'] != null ? (json['total_price']).toDouble() : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      customerName: json['profiles']?['full_name'] ?? json['walk_in_name'] ?? 'Walk-in',
      walkInName: json['walk_in_name'],
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isForOther: json['is_for_other'] ?? false,
      guestName: json['guest_name'],
      barber: json['barbers'] != null ? BarberModel.fromJson(json['barbers']) : null,
      service: json['services'] != null ? ServiceModel.fromJson(json['services']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'customer_id': userId,
      'barber_id': barberId,
      'service_id': serviceId,
      'booking_time': bookingDate.toIso8601String(),
      'status': status,
      'total_price': totalPrice,
      'walk_in_name': walkInName,
      'end_time': endTime?.toIso8601String(),
      'is_for_other': isForOther,
      'guest_name': guestName,
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? barberId,
    String? serviceId,
    DateTime? bookingDate,
    String? status,
    double? totalPrice,
    DateTime? createdAt,
    String? customerName,
    String? walkInName,
    DateTime? endTime,
    bool? isForOther,
    String? guestName,
    BarberModel? barber,
    ServiceModel? service,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barberId: barberId ?? this.barberId,
      serviceId: serviceId ?? this.serviceId,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      walkInName: walkInName ?? this.walkInName,
      endTime: endTime ?? this.endTime,
      isForOther: isForOther ?? this.isForOther,
      guestName: guestName ?? this.guestName,
      barber: barber ?? this.barber,
      service: service ?? this.service,
    );
  }
}
