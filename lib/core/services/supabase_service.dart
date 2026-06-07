import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  // Authentication Helpers
  User? get currentUser => client.auth.currentUser;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) {
    return client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() {
    return client.auth.signOut();
  }

  // Database Helpers Example
  // SupabaseQueryBuilder get profiles => client.from('profiles');
  // SupabaseQueryBuilder get bookings => client.from('bookings');
}
