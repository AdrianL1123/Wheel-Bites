import 'package:flutter_spin_to_eat/data/model/meal_vote.dart';

class Meal {
  int? id;
  String? userId;
  final String mealName;
  final String restaurantName;
  double? priceEstimate;
  final String img;
  final List<String> tags;
  final String notes;
  int upvotes;
  int downvotes;
  List<MealVote>? mealVotes;
  final bool isPublic;

  static const name = "meals";

  Meal({
    this.id,
    this.userId,
    required this.mealName,
    required this.restaurantName,
    this.priceEstimate,
    this.img = "",
    this.tags = const [],
    this.notes = "",
    this.isPublic = false,
    this.upvotes = 0,
    this.downvotes = 0,
    this.mealVotes,
  });

  Meal copy({
    int? id,
    String? userId,
    String? mealName,
    String? restaurantName,
    double? priceEstimate,
    String? img,
    List<String>? tags,
    String? notes,
    bool? isPublic,
    int? upvotes,
    int? downvotes,
    List<MealVote>? mealVotes,
  }) {
    return Meal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealName: mealName ?? this.mealName,
      restaurantName: restaurantName ?? this.restaurantName,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      img: img ?? this.img,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isPublic: isPublic ?? this.isPublic,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      mealVotes: mealVotes ?? this.mealVotes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "meal_name": mealName,
      "restaurant_name": restaurantName,
      "price_estimate": priceEstimate,
      "img": img,
      "tags": tags,
      "notes": notes,
      "is_public": isPublic,
      "upvotes": upvotes,
      "downvotes": downvotes,
    };
  }

  static Meal fromMap(Map<String, dynamic> mp) {
    return Meal(
      id: mp["id"],
      userId: mp["user_id"],
      mealName: mp["meal_name"],
      restaurantName: mp['restaurant_name'],
      priceEstimate:
          mp["price_estimate"] != null
              ? (mp["price_estimate"] as num).toDouble()
              : null,
      img: mp["img"],
      tags: List<String>.from(mp["tags"] ?? []),
      notes: mp["notes"],
      isPublic: mp["is_public"] ?? false,
      upvotes: mp["upvotes"],
      downvotes: mp["downvotes"],
      mealVotes:
          (mp["meal_votes"] as List<dynamic>?)
              ?.map((item) => MealVote.fromMap(item))
              .toList(),
    );
  }

  @override
  String toString() {
    return "Meal($id, $mealName, $restaurantName,$upvotes, $downvotes, $mealVotes, $priceEstimate)";
  }
}
