import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class QueueProvider extends ChangeNotifier {
  final SupabaseService _supabase;
  Map<String, dynamic>? _currentQueue;
  RealtimeChannel? _subscription;

  QueueProvider(this._supabase) {
    fetchQueue();
  }

  Map<String, dynamic>? get currentQueue => _currentQueue;
  bool get hasActiveQueue => _currentQueue != null;

  Future<void> fetchQueue() async {
    try {
      final user = _supabase.currentUser;
      if (user == null) {
        return;
      }

      // Find the most recent active booking for this customer
      final bookings = await _supabase.client
          .from('bookings')
          .select('id')
          .eq('customer_id', user.id)
          .inFilter('status', ['pending', 'confirmed'])
          .order('created_at', ascending: false)
          .limit(1);

      if (bookings.isNotEmpty) {
        final bookingId = bookings[0]['id'];
        
        // Listen to live queue updates using Supabase Realtime
        _subscription = _supabase.client
            .channel('public:queues')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'queues',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'booking_id',
                value: bookingId,
              ),
              callback: (payload) {
                _currentQueue = payload.newRecord;
                notifyListeners();
              },
            )
            .subscribe();

        // Initial fetch to get the current state
        final queues = await _supabase.client
            .from('queues')
            .select()
            .eq('booking_id', bookingId)
            .limit(1);
            
        if (queues.isNotEmpty) {
          _currentQueue = queues[0];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Queue fetch error: $e");
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
