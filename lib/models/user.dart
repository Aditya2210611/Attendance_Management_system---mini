enum UserRole { teacher, student }

class User {
  final String id;
  final String username;
  final String password;
  final String name;
  final UserRole role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, role: $role)';
  }
}

