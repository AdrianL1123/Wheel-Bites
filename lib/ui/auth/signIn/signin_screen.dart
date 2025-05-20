import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:flutter_spin_to_eat/service/auth_service.dart';
import 'package:flutter_spin_to_eat/utils/showToast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreen();
}

class _SigninScreen extends State<SigninScreen> {
  static final supabase = Supabase.instance.client;
  static final showToast = ShowToast();
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && mounted) {
        context.pushReplacementNamed(Screen.home.name);
      }
    });
  }

  void _signin() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = "Email cannot be empty";
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = "Password cannot be empty";
      });
      return;
    }

    try {
      await authService.signin(_emailController.text, _passwordController.text);
      if (mounted) {
        context.pushReplacementNamed(Screen.home.name);
        Future.delayed(Duration(milliseconds: 200), () {
          if (mounted) {
            showToast.success("Successfully logged in !", context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showToast.error("Something went wrong $e", context);
      }
    }
  }

  Future<void> _googleSignIn() async {
    final signInOption = GoogleSignIn(
      serverClientId: dotenv.env["SUPABASE_CLIENT_ID"],
    );

    final googleUser = await signInOption.signIn();
    final googleAuth = await googleUser!.authentication;

    final AuthResponse resp = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
    final user = resp.user;
    if (user != null) {
      // Insert user info into your users table (if not exists)
      await supabase.from("users").upsert({
        'id': user.id,
        'username': googleUser.displayName,
        'email': user.email,
      });
    }
    if (mounted) {
      context.pushReplacementNamed(Screen.home.name);
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          showToast.success("Successfully logged in !", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFF6B6B),
      body: Column(
        children: [
          // Top section
          Container(
            color: Color(0xFFFF6B6B),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Login to Wheel Meal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  "Welcome back",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          ),

          // Bottom section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFf6fff7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    labelText("Email"),
                    TextField(
                      onChanged:
                          (_) => setState(() {
                            _emailError = null;
                          }),
                      controller: _emailController,
                      decoration: InputDecoration(
                        errorText: _emailError,
                        hintText: "Enter Email...",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    labelText("Password"),
                    TextField(
                      obscureText: obscureText,
                      onChanged:
                          (_) => setState(() {
                            _passwordError = null;
                          }),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: "Enter password...",
                        errorText: _passwordError,
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon:
                              obscureText
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account yet? signup "),
                        GestureDetector(
                          onTap: () {
                            context.pushReplacementNamed(Screen.signup.name);
                          },
                          child: const Text(
                            "here",
                            style: TextStyle(
                              color: Color(0xFFff6b6b),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => _signin(),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(300, 55),
                        backgroundColor: const Color(0xFFff6b6b),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _googleSignIn,
                      icon: SvgPicture.asset(
                        'assets/icons8-google.svg',
                        height: 28,
                        width: 28,
                      ),
                      label: const Text("Sign in with Google"),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(300, 55),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget labelText(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
