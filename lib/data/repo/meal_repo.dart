import 'dart:async';

import 'package:flutter_spin_to_eat/data/model/meal.dart';
import 'package:flutter_spin_to_eat/data/model/meal_vote.dart';
import 'package:flutter_spin_to_eat/data/repo/meal_vote_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealRepo {
  static final MealRepo _instance = MealRepo._init();

  MealRepo._init();
  factory MealRepo() {
    return _instance;
  }

  final supabase = Supabase.instance.client;
  final mealVoteRepo = MealVoteRepo();

  Future<List<Meal>> getPublicMeals() async {
    final resp = await supabase
        .from("meals")
        .select('*, meal_votes(*)') // get relational data
        .eq("is_public", true)
        .order("id", ascending: false);

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

  Future<List<String>> getUserMealNames() async {
    final userId = supabase.auth.currentUser!.id;

    final resp = await supabase
        .from("meals")
        .select('meal_name')
        .eq("user_id", userId);

    return (resp).map((map) => map['meal_name'] as String).toList();
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
            // one resp or null
            .maybeSingle();

    if (resp == null) {
      return null;
    } else {
      return Meal.fromMap(resp);
    }
  }

  Future<void> addMeal(Meal meal) async {
    final userId = supabase.auth.currentUser?.id;
    // create meal and add userId before inserting into db
    final mealWithUser = meal.copy(userId: userId);
    await supabase.from("meals").insert(mealWithUser.toMap());
  }

  Future<void> deleteMeal(int id) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from("meals").delete().eq("user_id", userId).eq("id", id);
    }
    return;
  }

  Future<void> editMeal(Meal meal) async {
    final userId = supabase.auth.currentUser?.id;
    await supabase
        .from("meals")
        .update(meal.toMap())
        .eq("user_id", userId!)
        .eq('id', meal.id!);
  }

  Future<Meal> getUserMealsById(int id) async {
    final resp = await supabase.from("meals").select().eq("id", id).single();
    return Meal.fromMap(resp);
  }

  Future<void> upVoteMeal(int? mealId, int currentCount) async {
    final userId = supabase.auth.currentUser!.id;
    if (mealId == null) return;

    // Check if this user already voted this voteType on the meal
    final existingVote = await mealVoteRepo.checkIfVoteExists(mealId, 'upvote');

    if (existingVote == false) {
      // No existing vote: add vote and increment counter
      await mealVoteRepo.addVote(
        MealVote(userId: userId, mealId: mealId, voteType: 'upvote'),
      );

      await supabase
          .from('meals')
          .update({'upvotes': currentCount + 1})
          .eq('id', mealId);
    } else {
      // Vote exists: remove vote and decrement counter
      await mealVoteRepo.deleteVote(userId, mealId, 'upvote');

      await supabase
          .from('meals')
          .update(({'upvotes': currentCount - 1}))
          .eq('id', mealId);
    }
  }

  Future<void> downVoteMeal(int? mealId, int currentCount) async {
    final userId = supabase.auth.currentUser!.id;
    if (mealId == null) return;

    // Check if this user already voted this voteType on the meal
    final existingVote = await mealVoteRepo.checkIfVoteExists(
      mealId,
      'downvote',
    );

    if (existingVote == false) {
      // No existing vote: add vote and increment counter
      await mealVoteRepo.addVote(
        MealVote(userId: userId, mealId: mealId, voteType: 'downvote'),
      );

      await supabase
          .from('meals')
          .update({'downvotes': currentCount + 1})
          .eq('id', mealId);
    } else {
      // Vote exists: remove vote and decrement counter
      await mealVoteRepo.deleteVote(userId, mealId, 'downvote');

      await supabase
          .from('meals')
          .update(({'downvotes': currentCount - 1}))
          .eq('id', mealId);
    }
  }
}
