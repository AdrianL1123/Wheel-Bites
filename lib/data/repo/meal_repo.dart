import 'dart:async';

import 'package:flutter_spin_to_eat/data/model/meal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealRepo {
  static final MealRepo _instance = MealRepo._init();

  MealRepo._init();
  factory MealRepo() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<List<Meal>> getPublicMeals() async {
    final resp = await supabase
        .from("meals")
        .select()
        .eq("isPublic", true)
        .order("id", ascending: true);
    return resp.map((map) => Meal.fromMap(map)).toList();
  }

  Future<List<Meal>> getUserMeals() async {
    final userId = supabase.auth.currentUser!.id;
    final resp = await supabase
        .from("meals")
        .select()
        .eq("user_id", userId)
        .order("id", ascending: false);
    return resp.map((map) => Meal.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final userId = supabase.auth.currentUser!.id;

    final resp = await supabase
        .from("meals")
        .select("upvotes, downvotes")
        .eq("user_id", userId);

    final data = resp.toList();

    int totalMeals = data.length;
    int totalUpvotes = 0;
    int totalDownvotes = 0;

    for (var item in data) {
      totalUpvotes += (item['upvotes'] as int);
      totalDownvotes += (item['downvotes'] as int);
    }

    return {
      'totalMeals': totalMeals,
      'totalUpvotes': totalUpvotes,
      'totalDownvotes': totalDownvotes,
    };
  }

  Future<Meal?> getMostRecentUserMeal() async {
    final userId = supabase.auth.currentUser!.id;
    final resp =
        await supabase
            .from("meals")
            .select()
            .eq("user_id", userId)
            .order("id", ascending: false)
            .limit(1)
            .maybeSingle();

    if (resp == null) {
      return null;
    } else {
      return Meal.fromMap(resp);
    }
  }

  Future<void> addMeal(Meal meal) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final mealWithUser = meal.copy(userId: userId);
    await supabase.from("meals").insert(mealWithUser.toMap());
  }
}
