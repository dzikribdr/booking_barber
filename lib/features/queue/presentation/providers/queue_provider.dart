import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class QueueProvider extends ChangeNotifier {
  final SupabaseService _supabase;
  Map<String, dynamic>? _currentQueue;
  List<Map<String, dynamic>> _globalQueue = [];
  RealtimeChannel? _subscription;

  QueueProvider(this._supabase) {
    _supabase.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _currentQueue = null;
        _subscription?.unsubscribe();
        _subscription = null;
        notifyListeners();
      } else if (data.event == AuthChangeEvent.signedIn) {
        fetchQueue();
      }
    });
    fetchQueue();
  }

  Map<String, dynamic>? get currentQueue => _currentQueue;
  List<Map<String, dynamic>> get globalQueue => _globalQueue;
  bool get hasActiveQueue => _currentQueue != null;

  Future<void> fetchQueue() async {
    try {
      final user = _supabase.currentUser;
      if (user == null) return;

      // Listen to bookings table changes
      _subscription = _supabase.client
          .channel('public:bookings')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'bookings',
            callback: (payload) {
              _fetchAndCalculate();
            },
          )
          .subscribe();

      await _fetchAndCalculate();
    } catch (e) {
      debugPrint("Queue fetch error: $e");
    }
  }

  Future<void> _fetchAndCalculate() async {
    final user = _supabase.currentUser;
    if (user == null) {
      _currentQueue = null;
      notifyListeners();
      return;
    }

    // Get today's active bookings
    final todayStr = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final response = await _supabase.client
        .from('bookings')
        .select('*, barbers(name), services(name)')
        .gte('booking_time', '${todayStr}T00:00:00Z')
        .lte('booking_time', '${todayStr}T23:59:59Z')
        .inFilter('status', ['confirmed', 'in-progress'])
        .order('booking_time', ascending: true);

    final List<dynamic> allBookings = response;
    
    _globalQueue = List<Map<String, dynamic>>.from(allBookings);
    
    // Find my booking
    final myBookingIndex = allBookings.indexWhere((b) => b['customer_id'] == user.id);
    
    if (myBookingIndex != -1) {
      final myBooking = allBookings[myBookingIndex];
      int waitMinutes = 0;
      int servingIndex = 0;
      
      final now = DateTime.now();
      
      if (myBookingIndex == 0) {
        // I am next
        final bookingTime = DateTime.parse(myBooking['booking_time']).toLocal();
        waitMinutes = bookingTime.difference(now).inMinutes;
        servingIndex = 1; // You are the first
      } else {
        // Find the person right before me
        final prevBooking = allBookings[myBookingIndex - 1];
        if (prevBooking['end_time'] != null) {
          final prevEndTime = DateTime.parse(prevBooking['end_time']).toLocal();
          waitMinutes = prevEndTime.difference(now).inMinutes;
        } else {
          waitMinutes = 15 * myBookingIndex; // fallback
        }
        servingIndex = myBookingIndex + 1;
      }
      
      if (waitMinutes < 0) waitMinutes = 0; // Don't show negative wait time
      
      final barberName = myBooking['barbers'] != null ? myBooking['barbers']['name'] : 'Unknown Barber';
      final serviceName = myBooking['services'] != null ? myBooking['services']['name'] : 'Unknown Service';

      _currentQueue = {
        'booking_id': myBooking['id'],
        'queue_number': servingIndex,
        'estimated_wait_minutes': waitMinutes,
        'created_at': myBooking['created_at'],
        'barber_name': barberName,
        'service_name': serviceName,
        'barber_id': myBooking['barber_id'],
      };
      notifyListeners();
    } else {
      _currentQueue = null;
      notifyListeners();
    }
  }

  Future<void> cancelQueue() async {
    if (_currentQueue == null) return;
    
    final bookingId = _currentQueue!['booking_id'];
    
    try {
      // 1. Update queue status to cancelled
      await _supabase.client.from('queues').update({'status': 'cancelled'}).eq('booking_id', bookingId);
      
      // 2. Update booking status to cancelled
      await _supabase.client.from('bookings').update({'status': 'cancelled'}).eq('id', bookingId);
      
      // 3. Clear local state
      _currentQueue = null;
      _subscription?.unsubscribe();
      _subscription = null;
      notifyListeners();
      
    } catch (e) {
      debugPrint("Failed to cancel queue: $e");
    }
  }

  Future<void> completeQueue() async {
    if (_currentQueue == null) return;
    
    final bookingId = _currentQueue!['booking_id'];
    
    try {
      // 1. Update queue status to completed
      await _supabase.client.from('queues').update({'status': 'completed'}).eq('booking_id', bookingId);
      
      // 2. Update booking status to completed
      await _supabase.client.from('bookings').update({'status': 'completed'}).eq('id', bookingId);
      
      // 3. Clear local state
      _currentQueue = null;
      _subscription?.unsubscribe();
      _subscription = null;
      notifyListeners();
      
    } catch (e) {
      debugPrint("Failed to complete queue: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
