import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spin_to_eat/data/model/meal.dart';
import 'package:flutter_spin_to_eat/data/repo/meal_repo.dart';
import 'package:flutter_spin_to_eat/data/repo/user_repo.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:flutter_spin_to_eat/service/storage_service.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userRepo = UserRepo();
  final repo = MealRepo();
  final storageService = StorageService();
  var meals = <Meal>[];
  List<Uint8List?> bytes = [];
  bool isLoading = false;

  final _searchController = TextEditingController();
  String _searchQuery = "";
  List<Meal> _filteredMeals = [];
  List<Uint8List?> _filteredBytes = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUserMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      final filtered =
          meals
              .asMap()
              .entries
              .where(
                (entry) =>
                    entry.value.mealName.toLowerCase().contains(_searchQuery),
              )
              .toList();
      // filter to get the index and its value so that I can
      // display the appropriate image for the filtered meals
      _filteredMeals = filtered.map((entry) => entry.value).toList();
      _filteredBytes = filtered.map((entry) => bytes[entry.key]).toList();
    });
  }

  void _loadUserMeals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<Meal> resp = await repo.getUserMeals();
      final mealImages = <Uint8List?>[];
      for (final meal in resp) {
        final image = await storageService.getImage(meal.img);
        mealImages.add(image);
      }
      setState(() {
        meals = resp;
        _filteredMeals = resp;
        bytes = mealImages;
        _filteredBytes = mealImages;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('******************************');
      debugPrint('Error loading meals: $e');
      isLoading = false;
    }
  }

  void _navigateToDetailsPage(Meal meal) async {
    await context.pushNamed(
      Screen.details.name,
      pathParameters: {"id": meal.id.toString()},
    );
    _loadUserMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Personal Food Feed",
          style: TextStyle(
            color: Color(0xFFff6b6b),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.0),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search meals, restaurants...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            SizedBox(height: 16),
            // Meals List
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFff6b6b),
                        ),
                      )
                      : _filteredMeals.isEmpty
                      ? _noMealCard()
                      : ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: _filteredMeals.length,
                        itemBuilder: (context, index) {
                          final meal = _filteredMeals[index];
                          return _customMealCard(meal, index);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noMealCard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "No meals added yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add your favorite meals to see them here",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _customMealCard(Meal meal, int index) {
    return GestureDetector(
      onTap: () => _navigateToDetailsPage(meal),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
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
                  _filteredBytes.isNotEmpty &&
                          _filteredBytes.length > index &&
                          _filteredBytes[index] != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10.0),
                        ),
                        child: Image.memory(
                          _filteredBytes[index]!,
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
                  // Meal name
                  Text(
                    meal.mealName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  if (meal.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children:
                          meal.tags.map((tag) => _customTag(tag)).toList(),
                    ),

                  const SizedBox(height: 16),

                  // Restaurant
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFFff6b6b),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        meal.restaurantName,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  // Price estimate
                  if (meal.priceEstimate != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Color(0xFFff6b6b),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "~${meal.priceEstimate}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],

                  // Notes
                  if (meal.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      meal.notes,
                      style: TextStyle(color: Colors.grey[800], fontSize: 15),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(tag, style: TextStyle(fontSize: 13)),
    );
  }
}
