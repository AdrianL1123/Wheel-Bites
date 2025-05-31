import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spin_to_eat/data/model/meal.dart';
import 'package:flutter_spin_to_eat/data/repo/meal_repo.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:flutter_spin_to_eat/service/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final supabase = Supabase.instance.client;
  final repo = MealRepo();
  final storageService = StorageService();
  var meals = <Meal>[];
  List<Uint8List?> bytes = [];
  bool isLoading = false;

  Map<int, bool> hasUpVoted = {};
  Map<int, bool> hasDownVoted = {};

  final _searchController = TextEditingController();
  String _searchQuery = "";
  List<Meal> _filteredMeals = [];
  List<Uint8List?> _filteredBytes = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadPublicMeals();
  }

  void _loadPublicMeals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currUserId = supabase.auth.currentUser?.id;
      final resp = await repo.getPublicMeals();
      final mealImages = <Uint8List?>[];
      for (final meal in resp) {
        final image = await storageService.getImage(meal.img);
        mealImages.add(image);
        if (meal.id != null) {
          // another loop to check if user voted already for the meal
          if (meal.mealVotes != null) {
            for (final userVote in meal.mealVotes!) {
              if (userVote.userId == currUserId) {
                if (userVote.voteType == 'upvote') {
                  hasUpVoted[meal.id!] = true;
                } else if (userVote.voteType == 'downvote') {
                  hasDownVoted[meal.id!] = true;
                }
              }
            }
          }
        }
      }
      setState(() {
        meals = resp;
        _filteredMeals = resp;
        bytes = mealImages;
        _filteredBytes = mealImages;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading public meals: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToDetailsPage(Meal meal) async {
    await context.pushNamed(
      Screen.details.name,
      pathParameters: {"id": meal.id.toString()},
    );
    _loadPublicMeals();
  }

  void _upvote(Meal meal) async {
    if (meal.id == null) return;
    await repo.upVoteMeal(meal.id!, meal.upvotes);
    final vote = hasUpVoted[meal.id!] == true ? -1 : 1;
    final meals =
        _filteredMeals
            .map((m) => m.id == meal.id ? m.copy(upvotes: m.upvotes + vote) : m)
            .toList();
    setState(() {
      // Toggle the upvote status for this meal (true -> false, false/null -> true)
      hasUpVoted[meal.id!] = !(hasUpVoted[meal.id!] ?? false);
      _filteredMeals = meals;
    });
  }

  void _downvote(Meal meal) async {
    if (meal.id == null) return;
    await repo.downVoteMeal(meal.id!, meal.downvotes);
    final vote = hasDownVoted[meal.id!] == true ? -1 : 1;
    final meals =
        _filteredMeals
            .map(
              (m) =>
                  m.id == meal.id ? m.copy(downvotes: m.downvotes + vote) : m,
            )
            .toList();
    setState(() {
      // Toggle the downvote status for this meal (true -> false, false/null -> true)
      hasDownVoted[meal.id!] = !(hasDownVoted[meal.id!] ?? false);
      _filteredMeals = meals;
    });
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
      _filteredMeals = filtered.map((f) => f.value).toList();
      _filteredBytes = filtered.map((f) => bytes[f.key]).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Explore Meals",
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
            "No public meals available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
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

                  // VOTING SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        // Upvote
                        GestureDetector(
                          onTap: () => _upvote(meal),
                          child: Row(
                            children: [
                              hasUpVoted[meal.id] == true
                                  ? Icon(Icons.thumb_up_alt_rounded)
                                  : Icon(Icons.thumb_up_alt_outlined),

                              const SizedBox(width: 4),
                              Text(
                                '${meal.upvotes}',
                                style: TextStyle(color: Colors.green[800]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Downvote
                        GestureDetector(
                          onTap: () => _downvote(meal),
                          child: Row(
                            children: [
                              hasDownVoted[meal.id] == true
                                  ? Icon(Icons.thumb_down_alt_rounded)
                                  : Icon(Icons.thumb_down_off_alt_rounded),
                              const SizedBox(width: 4),
                              Text(
                                '${meal.downvotes}',
                                style: TextStyle(color: Colors.red[800]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
