import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_config.dart';
import '../models/login_response_model.dart';
import 'session_service.dart';

class AuthService {
  final SessionService _sessionService = SessionService();

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponseModel.fromJson(data);

      await _sessionService.saveSession(
        token: loginResponse.token,
        userId: loginResponse.user.id,
        username: loginResponse.user.username,
        role: loginResponse.user.role,
      );

      return loginResponse;
    }

    if (response.statusCode == 401) {
      throw Exception('Credenciales inválidas');
    }

    throw Exception('No se pudo iniciar sesión');
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
  }
}