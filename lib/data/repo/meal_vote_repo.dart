import 'package:flutter_spin_to_eat/data/model/meal_vote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealVoteRepo {
  static final MealVoteRepo _instance = MealVoteRepo._init();

  MealVoteRepo._init();
  factory MealVoteRepo() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<bool> checkIfVoteExists(int? mealId, String voteType) async {
    final userId = supabase.auth.currentUser!.id;

    if (mealId != null) {
      final resp =
          await supabase
              .from("meal_votes")
              .select()
              .eq("user_id", userId)
              .eq("meal_id", mealId)
              .eq("vote_type", voteType)
              .limit(1)
              .maybeSingle();

      return resp != null;
    }
    return false;
  }

  Future<void> addVote(MealVote mealVote) async {
    await supabase.from("meal_votes").insert(mealVote.toMap());
  }

  Future<void> deleteVote(String userId, int mealId, String voteType) async {
    await supabase
        .from("meal_votes")
        .delete()
        .eq("user_id", userId)
        .eq("meal_id", mealId)
        .eq("vote_type", voteType);
  }

  Future<void> updateVote(MealVote mealVote) async {
    await supabase
        .from("meal_votes")
        .update(mealVote.toMap())
        .eq("user_id", mealVote.userId)
        .eq("meal_id", mealVote.mealId);
  }
}
