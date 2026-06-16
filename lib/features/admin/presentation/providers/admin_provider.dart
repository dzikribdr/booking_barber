import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/barber_model.dart';
import '../../domain/models/service_model.dart';
import '../../domain/models/booking_model.dart';

class AdminProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Data Collections
  List<BarberModel> _barbers = [];
  List<BarberModel> get barbers => _barbers;

  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  // Dashboard Stats
  int get totalBookings => _bookings.length;
  int get activeStaff => _barbers.where((b) => b.status == 'active').length;
  int get totalCustomers => _bookings.map((b) => b.userId).toSet().length;
  double get dailyRevenue {
    final today = DateTime.now();
    return _bookings
        .where((b) => 
            b.status == 'completed' && 
            b.bookingDate.year == today.year && 
            b.bookingDate.month == today.month && 
            b.bookingDate.day == today.day)
        .fold(0.0, (sum, b) => sum + (b.totalPrice ?? 0.0));
  }

  AdminProvider() {
    fetchAllData();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchAllData() async {
    _setLoading(true);
    _setError(null);
    try {
      await Future.wait([
        fetchBarbers(),
        fetchServices(),
        fetchBookings(),
      ]);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- BARBER MANAGEMENT ---

  Future<void> fetchBarbers() async {
    try {
      final response = await _supabase.from('barbers').select().order('created_at', ascending: false);
      _barbers = (response as List).map((e) => BarberModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch barbers: $e');
    }
  }

  Future<void> addBarber(BarberModel barber) async {
    try {
      _setLoading(true);
      await _supabase.from('barbers').insert(barber.toJson());
      await fetchBarbers(); // Refresh
    } catch (e) {
      _setError('Failed to add barber: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBarber(BarberModel barber) async {
    try {
      _setLoading(true);
      await _supabase.from('barbers').update(barber.toJson()).eq('id', barber.id);
      await fetchBarbers();
    } catch (e) {
      _setError('Failed to update barber: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBarber(String id) async {
    try {
      _setLoading(true);
      await _supabase.from('barbers').delete().eq('id', id);
      await fetchBarbers();
    } catch (e) {
      _setError('Failed to delete barber: $e');
    } finally {
      _setLoading(false);
    }
  }

  // --- SERVICE MANAGEMENT ---

  Future<void> fetchServices() async {
    try {
      final response = await _supabase.from('services').select().order('created_at', ascending: false);
      _services = (response as List).map((e) => ServiceModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch services: $e');
    }
  }

  Future<void> addService(ServiceModel service) async {
    try {
      _setLoading(true);
      await _supabase.from('services').insert(service.toJson());
      await fetchServices();
    } catch (e) {
      _setError('Failed to add service: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      _setLoading(true);
      await _supabase.from('services').update(service.toJson()).eq('id', service.id);
      await fetchServices();
    } catch (e) {
      _setError('Failed to update service: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteService(String id) async {
    try {
      _setLoading(true);
      await _supabase.from('services').delete().eq('id', id);
      await fetchServices();
    } catch (e) {
      _setError('Failed to delete service: $e');
    } finally {
      _setLoading(false);
    }
  }

  // --- BOOKING MANAGEMENT ---

  Future<void> fetchBookings() async {
    try {
      // Using join query to get related barber and service data if possible,
      // or just fetching the raw bookings depending on setup.
      final response = await _supabase.from('bookings').select('*, barbers(*), services(*), profiles(*)').order('booking_time', ascending: false);
      _bookings = (response as List).map((e) => BookingModel.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch bookings: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      _setLoading(true);
      await _supabase.from('bookings').update({'status': newStatus}).eq('id', bookingId);
      await fetchBookings();
    } catch (e) {
      _setError('Failed to update booking status: $e');
    } finally {
      _setLoading(false);
    }
  }
}
