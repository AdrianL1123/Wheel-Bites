import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavigation extends StatelessWidget {
  final Widget child;
  const MainBottomNavigation({super.key, required this.child});

  // makes sure that the correct icon is highlighted based on the current URL path.
  int getCurrentIndex(BuildContext context) {
    final location =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/addMeal')) return 2;
    if (location.startsWith('/fortuneWheel')) return 3;
    if (location.startsWith('/profile')) return 4;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = getCurrentIndex(context);

    final List<String> routes = [
      Screen.home.name,
      Screen.explore.name,
      Screen.addMeal.name,
      Screen.fortuneWheel.name,
      Screen.profile.name,
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        onTap: (index) {
          context.goNamed(routes[index]);
        },
        items: [
          const Icon(Icons.home, size: 30),
          const Icon(Icons.map, size: 30),
          const Icon(Icons.add, size: 30),
          Image.asset("assets/lottery.png", scale: 18),
          const Icon(Icons.person, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Color(0xFFff6b6b),
      ),
    );
  }
}
