import 'auth_user_model.dart';

class LoginResponseModel {
  final String token;
  final AuthUserModel user;

  LoginResponseModel({
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json){
    return LoginResponseModel(
      token: json['token'] ?? '',
      user: AuthUserModel.fromJson(json['user'] ?? {}),
    );
  }
}