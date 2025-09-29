// lib/models/user.dart
class User {
  final int? id;
  final String fullname;
  final String username;
  final String email;
  final String password; // hashed

  User({
    this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'full_name': fullname,
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'] as int?,
    fullname: m['full_name'],
    username: m['username'],
    email: m['email'],
    password: m['password'],
  );
}
