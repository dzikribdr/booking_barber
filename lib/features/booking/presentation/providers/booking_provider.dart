import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../features/services/domain/entities/service_item.dart';

class BookingProvider extends ChangeNotifier {
  final SupabaseService _supabase;
  bool _isLoading = false;
  ServiceItem? _selectedService;
  
  RealtimeChannel? _bookingsSubscription;
  String? _currentViewedDate;
  String? _currentViewedBarberId;
  
  BookingProvider(this._supabase) {
    _initRealtimeSubscription();
  }
  
  void _initRealtimeSubscription() {
    _bookingsSubscription = _supabase.client
        .channel('public:bookings_selection')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            if (_currentViewedDate != null && _currentViewedBarberId != null) {
              fetchBookedTimes(_currentViewedDate!, _currentViewedBarberId!, isRefresh: true);
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _bookingsSubscription?.unsubscribe();
    super.dispose();
  }
  
  bool get isLoading => _isLoading;
  ServiceItem? get selectedService => _selectedService;
  
  List<String> _bookedTimes = [];
  List<String> get bookedTimes => _bookedTimes;

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

      // Check for overlapping bookings
      if (barberId.isNotEmpty) {
        final existingBookings = await _supabase.client
            .from('bookings')
            .select('id, booking_time, services(duration_minutes)')
            .eq('barber_id', barberId)
            .neq('status', 'cancelled')
            .gte('booking_time', '${bookingDate}T00:00:00Z')
            .lte('booking_time', '${bookingDate}T23:59:59Z');
            
        for (var b in existingBookings as List) {
           final bStart = DateTime.parse(b['booking_time']);
           int existingDuration = 30;
           if (b['services'] != null && b['services']['duration_minutes'] != null) {
             existingDuration = (b['services']['duration_minutes'] as num).toInt();
           }
           final bEnd = bStart.add(Duration(minutes: existingDuration));
           
           // Check overlap: start < bEnd AND end > bStart
           if (startDateTime.isBefore(bEnd) && endDateTime.isAfter(bStart)) {
              return "Waktu ini sudah dipesan oleh pelanggan lain. Silakan pilih waktu lain.";
           }
        }
      }

      // Insert booking matching the SQL schema
      final insertData = {
        'service_id': serviceId,
        if (barberId.isNotEmpty) 'barber_id': barberId,
        'booking_time': combinedDateTimeStr,
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

  List<Map<String, dynamic>> _topBarbers = [];
  List<Map<String, dynamic>> get topBarbers => _topBarbers;

  List<Map<String, dynamic>> _barberReviews = [];
  List<Map<String, dynamic>> get barberReviews => _barberReviews;
  
  bool _isLoadingReviews = false;
  bool get isLoadingReviews => _isLoadingReviews;
  
  String? _lastReviewError;
  String? get lastReviewError => _lastReviewError;

  Future<void> fetchTopBarbers() async {
    try {
      final data = await _supabase.client
          .from('barbers')
          .select()
          .eq('status', 'active')
          .order('rating', ascending: false)
          .limit(5); // Get top 5 barbers
      _topBarbers = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching top barbers: $e");
    }
  }

  Future<void> fetchBarberReviews(String barberId) async {
    _isLoadingReviews = true;
    _lastReviewError = null;
    notifyListeners();
    try {
      final data = await _supabase.client
          .from('barber_reviews')
          .select()
          .eq('barber_id', barberId)
          .order('created_at', ascending: false);
          
      final reviews = List<Map<String, dynamic>>.from(data);
      
      // Fetch profiles separately because there might not be a direct FK from barber_reviews to profiles
      if (reviews.isNotEmpty) {
        final customerIds = reviews.map((r) => r['customer_id']).where((id) => id != null).toSet().toList();
        if (customerIds.isNotEmpty) {
          try {
            final profilesData = await _supabase.client
                .from('profiles')
                .select('id, full_name')
                .inFilter('id', customerIds);
                
            final profilesMap = {for (var p in profilesData) p['id']: p};
            
            for (var review in reviews) {
              review['profiles'] = profilesMap[review['customer_id']];
            }
          } catch (profileError) {
            debugPrint("Error fetching profiles for reviews (RLS issue?): $profileError");
            // Lanjut saja, nama akan jadi Anonymous Customer jika gagal
          }
        }
      }
      
      _barberReviews = reviews;
    } catch (e) {
      debugPrint("Error fetching barber reviews (Main table issue): $e");
      _lastReviewError = e.toString();
      _barberReviews = [];
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  Future<String?> submitBarberRating(String bookingId, String barberId, double rating, String? review) async {
    try {
      final user = _supabase.currentUser;
      if (user == null) return "User not logged in";

      // 1. Insert into barber_reviews
      await _supabase.client.from('barber_reviews').insert({
        'booking_id': bookingId,
        'barber_id': barberId,
        'customer_id': user.id,
        'rating': rating,
        'review_text': review,
      });

      // 2. Update booking is_rated
      await _supabase.client.from('bookings').update({'is_rated': true}).eq('id', bookingId);

      // 3. Update barber rating (get current rating and reviews_count, then calculate new)
      final barberResponse = await _supabase.client.from('barbers').select('rating, reviews_count').eq('id', barberId).single();
      
      final currentRating = (barberResponse['rating'] ?? 0.0).toDouble();
      final currentReviewsCount = barberResponse['reviews_count'] ?? 0;
      
      final newReviewsCount = currentReviewsCount + 1;
      final newRating = ((currentRating * currentReviewsCount) + rating) / newReviewsCount;
      
      await _supabase.client.from('barbers').update({
        'rating': newRating,
        'reviews_count': newReviewsCount,
      }).eq('id', barberId);

      // Refresh history to update is_rated status locally
      await fetchBookingHistory();
      // Also refresh top barbers
      await fetchTopBarbers();
      
      return null; // success
    } catch (e) {
      debugPrint("Error submitting rating: $e");
      return e.toString();
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
          .select('*, services(name, price, duration_minutes), barbers(id, name)')
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

  Future<void> fetchBookedTimes(String date, String barberId, {bool isRefresh = false}) async {
    _currentViewedDate = date;
    _currentViewedBarberId = barberId;
    
    if (!isRefresh) {
      _isLoading = true;
      notifyListeners();
    }
    
    try {
      final startOfDay = '${date}T00:00:00Z';
      final endOfDay = '${date}T23:59:59Z';
      
      final data = await _supabase.client
          .from('bookings')
          .select('booking_time, services(duration_minutes)')
          .eq('barber_id', barberId)
          .gte('booking_time', startOfDay)
          .lte('booking_time', endOfDay)
          .neq('status', 'cancelled'); // Assumes cancelled bookings free up the slot
          
      debugPrint('SUPABASE BOOKINGS DATA: $data');

      Set<String> newBookedTimes = {};
      
      for (var e in data as List) {
        final startTimeStr = e['booking_time'] as String;
        int dur = 30;
        if (e['services'] != null && e['services']['duration_minutes'] != null) {
          dur = (e['services']['duration_minutes'] as num).toInt();
        }
        
        DateTime start = DateTime.parse(startTimeStr);
        DateTime end = start.add(Duration(minutes: dur));
        
        DateTime current = start;
        while (current.isBefore(end)) {
          final timeString = "${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}";
          newBookedTimes.add(timeString);
          current = current.add(const Duration(minutes: 30));
        }
      }
      _bookedTimes = newBookedTimes.toList();
      debugPrint('COMPUTED BOOKED TIMES: $_bookedTimes');
    } catch (e) {
      debugPrint("Error fetching booked times: $e");
      _bookedTimes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
