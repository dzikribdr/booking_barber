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
  double getRevenue(String filter) {
    final now = DateTime.now();
    DateTime startDate;

    if (filter == '7D') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (filter == '30D') {
      startDate = now.subtract(const Duration(days: 30));
    } else {
      // Today
      startDate = DateTime(now.year, now.month, now.day);
    }

    return _bookings.where((b) {
      if (b.status == 'cancelled') return false;
      
      if (filter == 'Today') {
        return b.bookingDate.year == now.year &&
               b.bookingDate.month == now.month &&
               b.bookingDate.day == now.day;
      }
      return b.bookingDate.isAfter(startDate) || b.bookingDate.isAtSameMomentAs(startDate);
    }).fold(0.0, (sum, b) => sum + (b.totalPrice ?? 0.0));
  }

  int getBookingsCount(String filter) {
    final now = DateTime.now();
    DateTime startDate;

    if (filter == '7D') {
      startDate = now.subtract(const Duration(days: 7));
    } else if (filter == '30D') {
      startDate = now.subtract(const Duration(days: 30));
    } else {
      // Today
      startDate = DateTime(now.year, now.month, now.day);
    }

    return _bookings.where((b) {
      if (b.status == 'cancelled') return false;

      if (filter == 'Today') {
        return b.bookingDate.year == now.year &&
               b.bookingDate.month == now.month &&
               b.bookingDate.day == now.day;
      }
      return b.bookingDate.isAfter(startDate) || b.bookingDate.isAtSameMomentAs(startDate);
    }).length;
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

  Future<void> fetchBookings() async {
    try {
      // Fetch raw bookings first
      final response = await _supabase.from('bookings').select().order('booking_time', ascending: false);
      
      final List<dynamic> bookingsData = response as List;
      
      // Fetch customer profiles if possible to avoid join errors
      final customerIds = bookingsData
          .map((e) => e['customer_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();
          
      Map<String, String> profileNames = {};
      if (customerIds.isNotEmpty) {
        try {
          final profilesResponse = await _supabase
              .from('profiles')
              .select('id, full_name')
              .filter('id', 'in', customerIds); // fallback for inFilter
          for (var p in profilesResponse) {
            profileNames[p['id'].toString()] = p['full_name'].toString();
          }
        } catch (e) {
          debugPrint('Failed to fetch profiles for bookings: $e');
        }
      }

      _bookings = bookingsData.map((e) {
        final Map<String, dynamic> json = Map.from(e);
        
        // Attach profile
        if (json['customer_id'] != null && profileNames.containsKey(json['customer_id'].toString())) {
          json['profiles'] = {'full_name': profileNames[json['customer_id'].toString()]};
        }
        
        // Attach barber from memory
        if (json['barber_id'] != null) {
          try {
            final barber = _barbers.firstWhere((b) => b.id == json['barber_id']);
            json['barbers'] = barber.toJson();
          } catch (_) {}
        }
        
        // Attach service from memory
        if (json['service_id'] != null) {
          try {
            final service = _services.firstWhere((s) => s.id == json['service_id']);
            json['services'] = service.toJson();
          } catch (_) {}
        }

        return BookingModel.fromJson(json);
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch bookings: $e');
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
