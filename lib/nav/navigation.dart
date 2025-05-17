import 'package:flutter_spin_to_eat/ui/home/home_screen.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  static const initial = "/";
  static final routes = [
    GoRoute(
      path: "/",
      name: Screen.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
  ];
}

enum Screen { home }
