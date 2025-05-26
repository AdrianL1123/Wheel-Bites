import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spin_to_eat/data/model/meal.dart';
import 'package:flutter_spin_to_eat/data/model/user.dart';
import 'package:flutter_spin_to_eat/data/repo/meal_repo.dart';
import 'package:flutter_spin_to_eat/data/repo/user_repo.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:flutter_spin_to_eat/service/auth_service.dart';
import 'package:flutter_spin_to_eat/service/storage_service.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userRepo = UserRepo();
  final repo = MealRepo();
  final authService = AuthService();
  final storageService = StorageService();
  AppUser? userInfo;
  Meal? meal;
  int? totalUpvotes;
  int? totalDownvotes;
  int? totalMeals;
  Uint8List? bytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getUserStats();
    _getUserMostRecentMeal();
  }

  void _getUserData() async {
    final resp = await userRepo.getUserDetails();
    setState(() {
      userInfo = resp;
    });
  }

  void _getUserStats() async {
    final resp = await repo.getUserStats();
    setState(() {
      totalMeals = resp['totalMeals'];
      totalUpvotes = resp['totalUpvotes'];
      totalDownvotes = resp['totalDownvotes'];
    });
  }

  void _getUserMostRecentMeal() async {
    setState(() => _isLoading = true);
    final resp = await repo.getMostRecentUserMeal();
    if (resp == null) {
      setState(() {
        meal = null;
        bytes = null;
        _isLoading = false;
      });
      return;
    }

    final imageBytes = await storageService.getImage(resp.img);
    setState(() {
      meal = resp;
      bytes = imageBytes;
      _isLoading = false;
    });

    debugPrint("******************************");
    debugPrint(meal.toString());
  }

  void _logout() async {
    await authService.signout();
    if (mounted) {
      context.pushReplacementNamed(Screen.signin.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile placeholder
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User name and location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo?.username ?? 'Jane Doe',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          userInfo?.email ?? 'JaneDoe@gmail.com',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _customStatsCard(
                      totalUpvotes?.toString() ?? '0',
                      'Upvotes',
                    ),
                    _customStatsCard(totalMeals?.toString() ?? '0', 'Meals'),
                    _customStatsCard(
                      totalDownvotes?.toString() ?? '0',
                      'Downvotes',
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 22.0, bottom: 6.0, left: 22.0),
                child: Text(
                  'My Latest Meal',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0, right: 22.0),
                child: const Divider(),
              ),

              SizedBox(height: 16.0),
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFff6b6b),
                          ),
                        )
                        : SingleChildScrollView(
                          child: Column(
                            children: [
                              meal == null
                                  ? _noMealCard()
                                  : _customMealCard(
                                    imageUrl: bytes,
                                    mealName: meal?.mealName ?? "N/A",
                                    tags: meal?.tags ?? [],
                                    location: meal?.restaurantName ?? "N/A",
                                    description: meal?.notes ?? "N/A",
                                    priceEstimate:
                                        meal?.priceEstimate.toString(),
                                  ),
                            ],
                          ),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFff6b6b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed:
                      () => {
                        showDialog(
                          context: context,
                          builder: (context) => _customDialog(),
                        ),
                      },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customDialog() {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SizedBox(
          width: double.infinity,
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header section
              Column(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 40,
                    color: Colors.redAccent[100],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This action cannot be undone",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  // Button section
                  SizedBox(height: 22.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _logout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFff6b6b),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Logout",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customStatsCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFFff6b6b),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
      ],
    );
  }

  Widget _customMealCard({
    Uint8List? imageUrl,
    required String mealName,
    required List<String> tags,
    required String location,
    String? priceEstimate,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal image
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
            ),
            child:
                imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.0),
                      ),
                      child: Image.memory(
                        bytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    )
                    : Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[500],
                        size: 40,
                      ),
                    ),
          ),

          // Meal details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal name and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mealName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  children: tags.map((tag) => _customTag(tag)).toList(),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFFff6b6b), size: 20),
                    const SizedBox(width: 8),
                    Text(location, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
                // user
                //... instead of {}
                if (priceEstimate != null) ...[
                  const SizedBox(height: 12),
                  // price estimate
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Color(0xFFff6b6b),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "~$priceEstimate",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],

                // Description
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noMealCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
            ),
            child: Center(
              child: Icon(Icons.fastfood, color: Colors.grey[500], size: 40),
            ),
          ),

          // Placeholder message
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No meals yet.\nAdd your first favorite meal!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(tag),
    );
  }
}
