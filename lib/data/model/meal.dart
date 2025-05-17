class Meal {
  final int id;
  final int userId;
  final String title;
  String? img;
  final String location;
  final List<String> tags;
  String? notes;
  final int upvotes;
  final int downvotes;
  final bool isPublic;

  static const name = "meals";

  Meal({
    required this.id,
    required this.userId,
    required this.title,
    required this.location,
    this.img,
    this.tags = const [],
    this.notes,
    this.isPublic = false,
    this.upvotes = 0,
    this.downvotes = 0,
  });
}
