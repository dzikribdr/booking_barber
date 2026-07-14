import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class QueueProvider extends ChangeNotifier {
  final SupabaseService _supabase;
  Map<String, dynamic>? _currentQueue;
  List<Map<String, dynamic>> _globalQueue = [];
  RealtimeChannel? _subscription;
  bool _lastEventWasCancel = false;

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
  bool get lastEventWasCancel => _lastEventWasCancel;

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
              if (payload.newRecord['status'] == 'cancelled') {
                _lastEventWasCancel = true;
              } else {
                _lastEventWasCancel = false;
              }
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
        .select('*, barbers(name), services(name, duration_minutes)')
        .gte('booking_time', '${todayStr}T00:00:00Z')
        .lte('booking_time', '${todayStr}T23:59:59Z')
        .inFilter('status', ['confirmed', 'in-progress'])
        .order('booking_time', ascending: true);

    final List<dynamic> allBookings = response;
    
    _globalQueue = List<Map<String, dynamic>>.from(allBookings);
    
    // Find my booking
    final myBookingIndexRaw = allBookings.indexWhere((b) => b['customer_id'] == user.id);
    
    if (myBookingIndexRaw != -1) {
      final myBooking = allBookings[myBookingIndexRaw];
      final myBarberId = myBooking['barber_id'];
      
      // Filter bookings for the same barber to calculate queue correctly
      final barberBookings = allBookings.where((b) => b['barber_id'] == myBarberId).toList();
      final myIndexInBarberQueue = barberBookings.indexWhere((b) => b['id'] == myBooking['id']);
      
      int totalQueueDuration = 0;
      
      // Sum the duration of all bookings ahead of me + my own
      for (int i = 0; i <= myIndexInBarberQueue; i++) {
        final b = barberBookings[i];
        final duration = b['services'] != null ? (b['services']['duration_minutes'] ?? 30) : 30;
        totalQueueDuration += (duration as num).toInt();
      }
      
      // Calculate elapsed time since this booking was created
      final createdAt = DateTime.parse(myBooking['created_at']).toLocal();
      final now = DateTime.now();
      final elapsedMinutes = now.difference(createdAt).inMinutes;
      int waitMinutes = totalQueueDuration - elapsedMinutes;
      if (waitMinutes < 0) waitMinutes = 0;
      
      // Dynamic queue number (shifts down when someone cancels or completes)
      int servingIndex = myBookingIndexRaw + 1;
      
      // Since it's a dynamic queue, the person currently being served is always at the front (index 0, so queue number 1).
      int currentlyServing = allBookings.isNotEmpty ? 1 : 0;
      
      final barberName = myBooking['barbers'] != null ? myBooking['barbers']['name'] : 'Unknown Barber';
      final serviceName = myBooking['services'] != null ? myBooking['services']['name'] : 'Unknown Service';

      _currentQueue = {
        'booking_id': myBooking['id'],
        'queue_number': servingIndex,
        'currently_serving': currentlyServing,
        'estimated_wait_minutes': waitMinutes,
        'created_at': myBooking['created_at'],
        'barber_name': barberName,
        'service_name': serviceName,
        'barber_id': myBarberId,
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
      
      // 3. Clear local state and refetch global queue immediately
      await _fetchAndCalculate();
      
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
      
      // 3. Clear local state and refetch global queue immediately
      await _fetchAndCalculate();
      
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
