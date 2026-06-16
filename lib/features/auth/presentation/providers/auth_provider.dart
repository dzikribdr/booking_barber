import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabase;
  User? _user;
  String? _fullName;
  String? _role;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._supabase) {
    _user = _supabase.currentUser;
    if (_user != null) {
      _fetchProfile(_user!.id);
    }

    _supabase.authStateChanges.listen((data) {
      final user = data.session?.user;
      if (user != null && (_user == null || user.id != _user!.id)) {
        _user = user;
        _fetchProfile(user.id);
      } else if (user == null) {
        _user = null;
        _fullName = null;
        _role = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await _supabase.client
          .from('profiles')
          .select('full_name, role')
          .eq('id', userId)
          .single();
      _fullName = data['full_name'] as String?;
      _role = data['role'] as String?;
    } catch (e) {
      debugPrint("Failed to fetch profile: $e");
    } finally {
      notifyListeners();
    }
  }

  User? get user => _user;
  String? get fullName => _fullName;
  String? get role => _role;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final res = await _supabase.signInWithEmail(email, password);
      if (res.user != null) {
        _user = res.user;
        await _fetchProfile(res.user!.id);
      }
      return true;
    } catch (e) {
      _errorMessage = e is AuthException ? e.message : e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final res = await _supabase.signUpWithEmail(email, password);
      if (res.user != null) {
        // Check if the user already exists (Supabase returns a fake user with empty identities for security)
        if (res.user!.identities != null && res.user!.identities!.isEmpty) {
          throw const AuthException('Email already registered. Please log in.');
        }

        // Create profile in DB
        await _supabase.client.from('profiles').insert({
          'id': res.user!.id,
          'full_name': fullName,
          'role': 'customer',
        });
      }
      return true;
    } catch (e) {
      _errorMessage = e is AuthException ? e.message : e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _supabase.signOut();
  }
}
