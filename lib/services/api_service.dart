import 'package:http/http.dart' as http;
import '../core/constants/api_config.dart';
import 'session_service.dart';

class ApiService {
  // Servicio de sesión para obtener el token almacenado en SharedPreferences.
  final SessionService _sessionService = SessionService();

  // Construye los headers comunes para todas las peticiones HTTP.
  // Incluye Content-Type y Authorization si hay token.
  Future<Map<String, String>> _buildHeaders() async {
    final token = await _sessionService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // Realiza una petición GET al endpoint indicado usando la URL base del API.
  Future<http.Response> get(String endpoint) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return await http.get(url, headers: headers);
  }

  // Realiza una petición POST al endpoint indicado con un body opcional.
  Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return await http.post(url, headers: headers, body: body);
  }

  // Realiza una petición PATCH al endpoint indicado con un body opcional.
  Future<http.Response> patch(String endpoint, {Object? body}) async {
    final headers = await _buildHeaders();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    return await http.patch(url, headers: headers, body: body);
  }
}