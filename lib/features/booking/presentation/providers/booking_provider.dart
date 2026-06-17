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
    required String barberId,
    required String bookingDate,
    required String bookingTime,
    required double totalAmount,
    bool isForOther = false,
    String? guestName,
    String? walkInName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.currentUser;
      if (user == null && walkInName == null) throw Exception("User not logged in");

      // Combine date and time to ISO 8601 format for timestamp with time zone
      final combinedDateTimeStr = '${bookingDate}T${bookingTime}Z';
      final startDateTime = DateTime.parse(combinedDateTimeStr);
      
      // Calculate end time
      final duration = _selectedService?.durationMinutes ?? 30;
      final endDateTime = startDateTime.add(Duration(minutes: duration));

      // Insert booking matching the SQL schema
      final insertData = {
        'service_id': serviceId,
        'barber_id': barberId,
        'booking_time': combinedDateTimeStr,
        'end_time': endDateTime.toIso8601String(),
        'status': 'confirmed', // Auto-confirm for demo purposes
        'total_price': totalAmount,
        'is_for_other': isForOther,
      };

      if (walkInName != null) {
        insertData['walk_in_name'] = walkInName;
        // customer_id is left null for walk-in if your DB allows it
      } else {
        insertData['customer_id'] = user!.id;
        if (guestName != null) {
          insertData['guest_name'] = guestName;
        }
      }

      final bookingResponse = await _supabase.client.from('bookings').insert(insertData).select().single();

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

  List<Map<String, dynamic>> _activeBarbers = [];
  List<Map<String, dynamic>> get activeBarbers => _activeBarbers;

  Future<void> fetchActiveBarbers() async {
    try {
      final data = await _supabase.client
          .from('barbers')
          .select()
          .eq('status', 'active');
      _activeBarbers = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching barbers: $e");
    }
  }

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
        } else if (statusFilter == 'transaction') {
          // Show all bookings for transaction history
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
