import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/customer_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  CustomerProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  CustomerProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseClient
          .from('customer_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        _profile = CustomerProfileModel.fromJson(response);
      } else {
        // Create default profile if not exists
        _profile = CustomerProfileModel(userId: userId);
        await _supabaseClient.from('customer_profiles').insert(_profile!.toJson());
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSilentMode(bool value) async {
    if (_profile == null) return;
    
    final oldProfile = _profile;
    _profile = _profile!.copyWith(isSilentMode: value);
    notifyListeners(); // Optimistic update

    try {
      await _supabaseClient
          .from('customer_profiles')
          .update({'is_silent_mode': value})
          .eq('user_id', _profile!.userId);
    } catch (e) {
      // Revert on failure
      _profile = oldProfile;
      _error = 'Gagal menyimpan preferensi: $e';
      notifyListeners();
    }
  }
}
