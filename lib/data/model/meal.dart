class Meal {
  String? id;
  String? userId;
  final String mealName;
  final String restaurantName;
  double? priceEstimate;
  String? img;
  final List<String> tags;
  String? notes;
  final int upvotes;
  final int downvotes;
  final bool isPublic;

  static const name = "meals";

  Meal({
    this.id,
    this.userId,
    required this.mealName,
    required this.restaurantName,
    this.priceEstimate,
    this.img,
    this.tags = const [],
    this.notes,
    this.isPublic = false,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  Meal copy({
    String? id,
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
      priceEstimate: (mp["price_estimate"]),
      img: mp["img"],
      tags: List<String>.from(mp["tags"] ?? []),
      notes: mp["notes"],
      isPublic: mp["is_public"] ?? false,
      upvotes: mp["upvotes"] ?? 0,
      downvotes: mp["downvotes"] ?? 0,
    );
  }

  @override
  String toString() {
    return "Meal($id, $mealName, $restaurantName, ${priceEstimate ?? 'N/A'})";
  }
}
