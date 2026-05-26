import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import 'session_service.dart';

class ApiService {
  final SessionService _sessionService = SessionService();

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _sessionService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final encodedBody = body == null || body is String ? body : jsonEncode(body);

    return await http.post(url, headers: headers, body: encodedBody);
  }

  Future<http.Response> patch(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final encodedBody = body == null || body is String ? body : jsonEncode(body);

    return await http.patch(url, headers: headers, body: encodedBody);
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return await http.delete(url, headers: headers);
  }
}