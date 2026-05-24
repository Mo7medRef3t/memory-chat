import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource(this.client);

  Stream<AuthState> authStateChanges() {
    return client.auth.onAuthStateChange;
  }

  User? getCurrentAuthUser() {
    return client.auth.currentUser;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signOut() {
    return client.auth.signOut();
  }
}
