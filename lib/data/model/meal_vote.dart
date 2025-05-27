class MealVote {
  int? id;
  final String userId;
  final int mealId;
  final String voteType;

  MealVote({
    this.id,
    required this.userId,
    required this.mealId,
    required this.voteType,
  });

  factory MealVote.fromMap(Map<String, dynamic> map) {
    return MealVote(
      id: map['id'],
      userId: map['user_id'],
      mealId: map['meal_id'],
      voteType: map['vote_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'user_id': userId, 'meal_id': mealId, 'vote_type': voteType};
  }
}
