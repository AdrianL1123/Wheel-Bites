import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_spin_to_eat/data/repo/meal_repo.dart';
import 'package:flutter_spin_to_eat/utils/showToast.dart';

class FortuneWheelScreen extends StatefulWidget {
  const FortuneWheelScreen({super.key});

  @override
  State<FortuneWheelScreen> createState() => _FortuneWheelScreenState();
}

class _FortuneWheelScreenState extends State<FortuneWheelScreen> {
  final StreamController<int> controller = StreamController<int>();
  final repo = MealRepo();
  var meals = <String>[];
  bool isLoading = false;
  int? outcome;
  String? selectedMeal;

  @override
  void initState() {
    super.initState();
    _loadUserMeals();
  }

  void _loadUserMeals() async {
    setState(() => isLoading = true);

    try {
      final resp = await repo.getUserMealNames();
      setState(() {
        meals = resp;
        isLoading = false;
      });
      debugPrint(meals.toString());
    } catch (e) {
      if (mounted) {
        ShowToast.error("Something went wrong $e", context);
      }
      setState(() => isLoading = false);
    }
  }

  void _spinWheel() {
    meals.isNotEmpty
        ? controller.add(outcome = Fortune.randomInt(0, meals.length))
        : controller.add(outcome = Fortune.randomInt(0, 4));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Spin To Eat",
          style: TextStyle(
            color: Color(0xFFff6b6b),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFFff6b6b)),
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  selectedMeal != null
                      ? _selectedMealCard(selectedMeal!)
                      : _headerCard(),
                  SizedBox(height: 52.0),
                  SizedBox(
                    height: 350,
                    child: FortuneWheel(
                      // changing the return animation when the user stops dragging
                      physics: CircularPanPhysics(
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOutCubic,
                      ),
                      onFling: () => _spinWheel(),
                      onAnimationEnd: () {
                        setState(() {
                          selectedMeal = meals[outcome!];
                        });
                      },
                      animateFirst: false,
                      hapticImpact: HapticImpact.light,
                      selected: controller.stream,
                      indicators: <FortuneIndicator>[
                        FortuneIndicator(
                          alignment: Alignment.topCenter,
                          child: TriangleIndicator(
                            color: Color(0xFFe55555),
                            width: 20.0,
                            height: 20.0,
                          ),
                        ),
                      ],
                      items:
                          meals.isNotEmpty
                              // use the index to switch between colors
                              ? meals.asMap().entries.map((entry) {
                                final index = entry.key;
                                final meal = entry.value;
                                final isEven = index % 2 == 0;

                                return FortuneItem(
                                  child: Text(
                                    meal,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: FortuneItemStyle(
                                    color:
                                        isEven
                                            ? Color(0xFFff8e8e)
                                            : Color(0xFFff9e9e),
                                    borderColor: Color(0xFFff8e8e),
                                    borderWidth: 2,
                                  ),
                                );
                              }).toList()
                              : [
                                FortuneItem(child: Text("Chinese Cuisine")),
                                FortuneItem(child: Text("Malay Cuisine")),
                                FortuneItem(child: Text("Indian Cuisine")),
                                FortuneItem(child: Text("Western Cuisine")),
                              ],
                    ),
                  ),
                  SizedBox(height: 32.0),
                  // Spin Button
                  SizedBox(
                    width: 200,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _spinWheel(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFff6b6b),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Color(0xFFff6b6b),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino, size: 24),
                          SizedBox(width: 12),
                          Text(
                            "Spin the Wheel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }
}

Widget _headerCard() {
  return Padding(
    padding: const EdgeInsets.only(left: 32.0, right: 32.0),
    child: Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.casino,
            size: 36,
            color: Color(0xFFff6b6b),
          ), // smaller icon
          SizedBox(height: 12),
          Text(
            "Don't know what to eat ?",
            style: TextStyle(
              fontSize: 16, // smaller font
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            "Let fate decide!",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _selectedMealCard(String selectedMeal) {
  return Padding(
    padding: const EdgeInsets.only(left: 32.0, right: 32.0),
    child: Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFff6b6b), Color(0xFFff8e8e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFff6b6b),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, color: Colors.white, size: 32),
          SizedBox(height: 12),
          Text(
            "Your meal is:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            selectedMeal,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
