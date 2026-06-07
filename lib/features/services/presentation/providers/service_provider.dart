import 'package:flutter/material.dart';
import '../../domain/entities/service_item.dart';
import '../../../../core/services/supabase_service.dart';

class ServiceProvider extends ChangeNotifier {
  final SupabaseService _supabase;
  List<ServiceItem> _services = [];
  bool _isLoading = false;

  ServiceProvider(this._supabase) {
    Future.microtask(() => fetchServices());
  }

  List<ServiceItem> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.client.from('services').select();
      _services = (response as List).map((e) => ServiceItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching services: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
