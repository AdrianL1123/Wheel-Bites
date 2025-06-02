import 'package:flutter_spin_to_eat/main_bottom_navigation.dart';
import 'package:flutter_spin_to_eat/ui/addMeal/add_meal_screen.dart';
import 'package:flutter_spin_to_eat/ui/auth/signIn/signin_screen.dart';
import 'package:flutter_spin_to_eat/ui/auth/signup/signup_screen.dart';
import 'package:flutter_spin_to_eat/ui/details/details_screen.dart';
import 'package:flutter_spin_to_eat/ui/editMeal/edit_meal_screen.dart';
import 'package:flutter_spin_to_eat/ui/explore/explore_screen.dart';
import 'package:flutter_spin_to_eat/ui/fortuneWheel/fortune_wheel_screen.dart';
import 'package:flutter_spin_to_eat/ui/home/home_screen.dart';
import 'package:flutter_spin_to_eat/ui/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';

class Navigation {
  static const initial = "/signIn";
  static final routes = [
    GoRoute(
      path: "/signIn",
      name: Screen.signin.name,
      builder: (context, state) => const SigninScreen(),
    ),
    GoRoute(
      path: "/signup",
      name: Screen.signup.name,
      builder: (context, state) => const SignupScreen(),
    ),
    /**
   * ShellRoute allows grouping multiple routes under a common UI shell, which in this case is MainBottomNavigation.
   * It keeps the shell UI persistent and swaps only the 'child' widget when navigating between routes.
   * The CHILD passed to MainBottomNavigation represents the currently active page,
   * so that it navigates to the correct page while still displaying MainBottomNavigation
   */
    ShellRoute(
      builder: (context, state, child) {
        return MainBottomNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: "/",
          name: Screen.home.name,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: "/explore",
          name: Screen.explore.name,
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: "/addMeal",
          name: Screen.addMeal.name,
          builder: (context, state) => const AddMealScreen(),
        ),
        GoRoute(
          path: "/details/:id",
          name: Screen.details.name,
          builder:
              (context, state) =>
                  DetailsScreen(id: (state.pathParameters["id"]!)),
        ),
        GoRoute(
          path: "/editMeal/:id",
          name: Screen.editMeal.name,
          builder:
              (context, state) =>
                  EditMealScreen(id: state.pathParameters["id"]!),
        ),
        GoRoute(
          path: "/fortuneWheel",
          name: Screen.fortuneWheel.name,
          builder: (context, state) => const FortuneWheelScreen(),
        ),
        GoRoute(
          path: "/profile",
          name: Screen.profile.name,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ];
}

enum Screen {
  main,
  home,
  details,
  signin,
  signup,
  fortuneWheel,
  profile,
  addMeal,
  editMeal,
  explore,
}
