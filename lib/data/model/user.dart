class AppUser {
  String? id;
  final String username;
  final String email;

  AppUser({this.id, required this.username, required this.email});

  factory AppUser.fromMap(Map<String, dynamic> map) =>
      AppUser(id: map['id'], username: map['username'], email: map['email']);

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
  };
}
