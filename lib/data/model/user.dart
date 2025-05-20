class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromMap(Map<String, dynamic> map) =>
      User(id: map['id'], username: map['username'], email: map['email']);

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
  };
}
