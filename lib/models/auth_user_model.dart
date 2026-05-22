class AuthUserModel {
  final int id;
  final String username;
  final String role;

  AuthUserModel({
    required this.id,
    required this.username,
    required this.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json){
    return AuthUserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );

  }

}