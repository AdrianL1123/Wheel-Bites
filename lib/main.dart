import 'package:flutter/material.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://yhxztknoxahmlawqyffe.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InloeHp0a25veGFobWxhd3F5ZmZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0NjA0NTUsImV4cCI6MjA2MzAzNjQ1NX0.ZUbnk4tSzinOBgsWHFH3ZzLXVgfjAnTyX2g0mZD1RU8",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: GoRouter(
        initialLocation: Navigation.initial,
        routes: Navigation.routes,
      ),
    );
  }
}
