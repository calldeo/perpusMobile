import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final List<Role> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((roleJson) => Role.fromJson(roleJson))
          .toList(),
    );
  }
}

class Role {
  final int id;
  final String name;
  final String guardName;

  Role({
    required this.id,
    required this.name,
    required this.guardName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      guardName: json['guard_name'] ?? '',
    );
  }
}
