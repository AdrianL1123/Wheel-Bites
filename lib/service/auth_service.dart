import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<Map<String, dynamic>> googleSignIn() async {
    final signInOption = GoogleSignIn(
      serverClientId: dotenv.env["SUPABASE_CLIENT_ID"],
    );

    // Sign out first to force showing the account picker every time
    await signInOption.signOut();
    final googleUser = await signInOption.signIn();
    final googleAuth = await googleUser!.authentication;

    final AuthResponse resp = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
    return {'user': resp.user, 'googleUser': googleUser};
  }

  // Sign out / logout
  Future<void> signout() async {
    return await supabase.auth.signOut();
  }
}
