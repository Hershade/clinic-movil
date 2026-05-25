import 'dart:convert';

import 'package:http/http.dart' as http;
import '/core/constants/api_config.dart';
import 'session_service.dart';

class ApiService {
  // Servicio de sesión para obtener el token almacenado en SharedPreferences.
  final SessionService _sessionService = SessionService();
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Construye los headers comunes para todas las peticiones HTTP.
  // Incluye Content-Type y Authorization si hay token.
  Future<Map<String, String>> _buildHeaders() async {
    final token = await _sessionService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _withTimeout(Future<http.Response> call) async {
    try {
      return await call.timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Realiza una petición GET al endpoint indicado usando la URL base del API.
  Future<http.Response> get(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return _withTimeout(_client.get(url, headers: headers));
  }

  // Realiza una petición POST al endpoint indicado con un body opcional.
  Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return _withTimeout(_client.post(url, headers: headers, body: body));
  }

  Future<http.Response> postJson(String endpoint, Map<String, dynamic> data) async {
    return post(endpoint, body: jsonEncode(data));
  }

  // Realiza una petición PATCH al endpoint indicado con un body opcional.
  Future<http.Response> patch(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return _withTimeout(_client.patch(url, headers: headers, body: body));
  }

  Future<http.Response> patchJson(String endpoint) async {
    return patch(endpoint, body: jsonEncode({}));
  }

  Future<http.Response> patchJsonWithBody(String endpoint, Map<String, dynamic> data) async {
    return patch(endpoint, body: jsonEncode(data));
  }

  Future<http.Response> put(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return _withTimeout(_client.put(url, headers: headers, body: body));
  }

  Future<http.Response> putJson(String endpoint, Map<String, dynamic> data) async {
    return put(endpoint, body: jsonEncode(data));
  }
}