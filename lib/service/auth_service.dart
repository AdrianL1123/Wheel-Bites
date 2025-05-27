import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._init();
  AuthService._init();

  factory AuthService() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  // Sign in / Login with Email and Password
  Future<AuthResponse> signin(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with Email and Password
  Future<AuthResponse> signup(
    String email,
    String password,
    String username,
  ) async {
    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {"username": username},
    );
    // add user into db
    if (res.user != null) {
      await supabase.from('users').insert({
        'id': res.user?.id,
        'username': username,
        'email': email,
      });
      return res;
    } else {
      throw Exception('User sign up failed');
    }
  }

  // Sign out / logout
  Future<void> signout() async {
    return await supabase.auth.signOut();
  }

  // Get user details
  User? getSignedInUser() {
    return supabase.auth.currentUser;
  }
}
