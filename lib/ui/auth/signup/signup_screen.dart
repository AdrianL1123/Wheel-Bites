import 'package:flutter/material.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:flutter_spin_to_eat/service/auth_service.dart';
import 'package:flutter_spin_to_eat/utils/show_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static final supabase = Supabase.instance.client;
  final authService = AuthService();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _userNameError;
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

  void _signup() async {
    final userName = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (userName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        if (userName.isEmpty) _userNameError = "Username cannot be empty";
        if (email.isEmpty) _emailError = "Email cannot be empty";
        if (password.isEmpty) _passwordError = "Password cannot be empty";
      });
    }

    try {
      await authService.signup(email, password, userName);
      if (mounted) {
        context.pushReplacementNamed(Screen.home.name);
        if (mounted) ShowToast.success("Successfully Signed up !", context);
      }
    } on AuthException catch (e) {
      if (mounted) ShowToast.error(e.message, context);
    }
  }

  Future<void> _googleSignIn() async {
    try {
      final result = await authService.googleSignIn();
      final user = result['user'];
      if (user != null) {
        // Insert user info into your users table (if not exists)
        await supabase.from("users").upsert({
          'id': user.id,
          'username': result['googleUser'].displayName,
          'email': user.email,
        });
      }
      if (mounted) {
        context.pushReplacementNamed(Screen.home.name);
      }
    } on AuthException catch (e) {
      if (mounted) ShowToast.error(e.message, context);
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
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Sign up for Wheel Meal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Welcome",
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
                    labelText("Username"),
                    TextField(
                      onChanged:
                          (_) => setState(() {
                            _userNameError = null;
                          }),
                      controller: _usernameController,
                      decoration: InputDecoration(
                        errorText: _userNameError,
                        hintText: "Enter Username...",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 16.0),
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
                    SizedBox(height: 16.0),
                    labelText("Password"),
                    TextField(
                      obscureText: obscureText,
                      onChanged:
                          (_) => setState(() {
                            _passwordError = null;
                          }),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        errorText: _passwordError,
                        hintText: "Enter Password...",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon:
                              obscureText
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                          onPressed:
                              () => setState(() {
                                obscureText = !obscureText;
                              }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account ? signin "),
                        GestureDetector(
                          onTap: () {
                            context.pushReplacementNamed(Screen.signin.name);
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
                      onPressed: () => _signup(),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(300, 55),
                        backgroundColor: const Color(0xFFff6b6b),
                      ),
                      child: const Text(
                        'Sign Up',
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
