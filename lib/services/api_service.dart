import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/api_config.dart';
import 'session_service.dart';

class ApiService {
  final SessionService _sessionService = SessionService();
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<http.Response> get(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return _withTimeout(_client.get(url, headers: headers));
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final encodedBody = body == null || body is String ? body : jsonEncode(body);

    return _withTimeout(_client.post(url, headers: headers, body: encodedBody));
  }

  Future<http.Response> postJson(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return post(endpoint, body: jsonEncode(data));
  }

  Future<http.Response> patch(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final encodedBody = body == null || body is String ? body : jsonEncode(body);

    return _withTimeout(
      _client.patch(url, headers: headers, body: encodedBody),
    );
  }

  Future<http.Response> patchJson(String endpoint) async {
    return patch(endpoint, body: jsonEncode({}));
  }

  Future<http.Response> patchJsonWithBody(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return patch(endpoint, body: jsonEncode(data));
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return _withTimeout(_client.delete(url, headers: headers));
  }

  Future<http.Response> put(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final encodedBody = body == null || body is String ? body : jsonEncode(body);

    return _withTimeout(_client.put(url, headers: headers, body: encodedBody));
  }

  Future<http.Response> putJson(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return put(endpoint, body: jsonEncode(data));
  }
}