import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spin_to_eat/data/model/meal.dart';
import 'package:flutter_spin_to_eat/data/repo/meal_repo.dart';
import 'package:flutter_spin_to_eat/nav/navigation.dart';
import 'package:flutter_spin_to_eat/service/storage_service.dart';
import 'package:flutter_spin_to_eat/utils/show_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final repo = MealRepo();
  final storageService = StorageService();
  final userId = Supabase.instance.client.auth.currentUser?.id;

  Meal? meal;
  bool isLoading = false;
  Uint8List? mealImage;

  @override
  void initState() {
    _loadUserMeal();
    super.initState();
  }

  void _loadUserMeal() async {
    setState(() {
      isLoading = true;
    });
    final fetchedMeal = await repo.getUserMealsById(int.parse(widget.id));
    final imageBytes = await storageService.getImage(fetchedMeal.img);
    setState(() {
      meal = fetchedMeal;
      mealImage = imageBytes;
      isLoading = false;
    });
  }

  void _editMeal(Meal? meal) async {
    if (meal == null) return;
    await context.pushNamed(
      Screen.editMeal.name,
      pathParameters: {"id": meal.id.toString()},
    );
  }

  void _deleteMeal() async {
    try {
      await repo.deleteMeal(meal!.id!);

      if (mounted) {
        context.pop();
        context.goNamed(Screen.home.name);
        Future.delayed(Duration(milliseconds: 200), () {
          if (mounted) {
            ShowToast.success("Successfully deleted meal !", context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ShowToast.error("Failed to delete meal", context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meal?.mealName ?? "")),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFFff6b6b)),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _customImageBox(),
                    _contentSection(),
                    const SizedBox(height: 80),
                    if (meal != null && meal?.userId == userId) ...[
                      _customBottomButtons(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _customImageBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 280,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child:
            mealImage != null
                ? Image.memory(
                  mealImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
                : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.restaurant, size: 60, color: Colors.grey),
                  ),
                ),
      ),
    );
  }

  Widget _contentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _customTags(),
          const SizedBox(height: 24),
          _buildDetailsSection(),
          const SizedBox(height: 24),
          _customStats(),
          const SizedBox(height: 24),
          if (meal!.notes.isNotEmpty) _customNotesSection(),
        ],
      ),
    );
  }

  Widget _sectionBuilder({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFff6b6b), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _customTags() {
    return _sectionBuilder(
      title: 'Tags',
      icon: Icons.label,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: meal!.tags.map((tag) => _customTag(tag)).toList(),
      ),
    );
  }

  Widget _customTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFff6b6b),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(tag, style: TextStyle(fontSize: 13, color: Colors.white)),
    );
  }

  Widget _buildDetailsSection() {
    return _sectionBuilder(
      title: 'Details',
      icon: Icons.info_outline,
      child: Row(
        children: [
          Expanded(
            child: _customInfoCard(
              icon: Icons.attach_money,
              value: "~${meal?.priceEstimate}",
              label: 'Price',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _customInfoCard(
              icon: Icons.location_on,
              value: meal?.restaurantName ?? 'N/A',
              label: 'Restaurant',
              isText: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customStats() {
    return _sectionBuilder(
      title: 'Community Feedback',
      icon: Icons.trending_up,
      child: Row(
        children: [
          Expanded(
            child: _customInfoCard(
              icon: Icons.thumb_up,
              value: '${meal?.upvotes ?? 0}',
              label: 'Upvotes',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _customInfoCard(
              icon: Icons.thumb_down,
              value: '${meal?.downvotes ?? 0}',
              label: 'Downvotes',
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customNotesSection() {
    return _sectionBuilder(
      title: 'Notes',
      icon: Icons.note,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: Color(0xFFff6b6b), width: 4),
          ),
        ),
        child: Text(
          meal!.notes,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _customInfoCard({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
    bool isText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color ?? const Color(0xFFff6b6b)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isText ? 14 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2c3e50),
            ),
            textAlign: TextAlign.center,
            maxLines: isText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _customBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () => _editMeal(meal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Edit",
                    style: TextStyle(
                      color: Color(0xFFff6b6b),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                      builder: (context) => _deleteMealDialog(),
                    ),
                  },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Delete",
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
    );
  }

  Widget _deleteMealDialog() {
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
                  Icon(Icons.food_bank, size: 40, color: Colors.redAccent[100]),
                  const SizedBox(height: 16),
                  Text(
                    "Are you sure you want to delete this meal ?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Action will not be reversible",
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
                          onPressed: () => _deleteMeal(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFff6b6b),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'delete',
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
}
