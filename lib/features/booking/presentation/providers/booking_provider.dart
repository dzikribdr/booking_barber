import 'package:flutter/material.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../features/services/domain/entities/service_item.dart';

class BookingProvider extends ChangeNotifier {
  final SupabaseService _supabase;
  bool _isLoading = false;
  ServiceItem? _selectedService;
  
  BookingProvider(this._supabase);
  
  bool get isLoading => _isLoading;
  ServiceItem? get selectedService => _selectedService;

  void setService(ServiceItem service) {
    _selectedService = service;
    notifyListeners();
  }

  Future<String?> createBooking({
    required String serviceId,
    required String bookingDate,
    required String bookingTime,
    required double totalAmount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Combine date and time to ISO 8601 format for timestamp with time zone
      final combinedDateTime = '${bookingDate}T${bookingTime}Z';

      // Insert booking matching the SQL schema
      final bookingResponse = await _supabase.client.from('bookings').insert({
        'customer_id': user.id,
        'service_id': serviceId,
        'booking_time': combinedDateTime,
        'status': 'confirmed', // Auto-confirm for demo purposes
      }).select().single();

      // Get the highest queue number for today to make it sequential
      final today = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(today.year, today.month, today.day).toIso8601String();
      
      final lastQueue = await _supabase.client
          .from('queues')
          .select('queue_number')
          .gte('created_at', startOfDay)
          .order('queue_number', ascending: false)
          .limit(1);
          
      int nextQueueNumber = 1;
      if (lastQueue.isNotEmpty) {
        nextQueueNumber = (lastQueue[0]['queue_number'] as int) + 1;
      }

      // Insert queue entry
      await _supabase.client.from('queues').insert({
        'booking_id': bookingResponse['id'],
        'queue_number': nextQueueNumber,
        'status': 'waiting',
        'estimated_wait_minutes': 15, // Baseline wait per person, can be dynamic
      });

      return null; // Success (no error)
    } catch (e) {
      debugPrint("Error creating booking: $e");
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  List<Map<String, dynamic>> _bookingHistory = [];
  List<Map<String, dynamic>> get bookingHistory => _bookingHistory;

  Future<void> fetchBookingHistory({String? statusFilter}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _supabase.currentUser;
      if (user == null) throw Exception("User not logged in");

      var filterBuilder = _supabase.client
          .from('bookings')
          .select('*, services(name, price, duration_minutes)')
          .eq('customer_id', user.id);

      if (statusFilter != null && statusFilter != 'all') {
        if (statusFilter == 'ongoing') {
          filterBuilder = filterBuilder.inFilter('status', ['pending', 'confirmed']);
        } else {
          filterBuilder = filterBuilder.eq('status', statusFilter);
        }
      }

      final data = await filterBuilder.order('booking_time', ascending: false);
      _bookingHistory = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint("Error fetching booking history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
