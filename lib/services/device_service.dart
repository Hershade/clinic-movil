import 'dart:convert';
import 'api_service.dart';

class DeviceService {
  final ApiService _apiService = ApiService();

  Future<void> registerToken({
    required String token,
    String platform = 'android',
  }) async {
    final response = await _apiService.post(
      '/devices/token',
      body: jsonEncode({
        'token': token,
        'platform': platform,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado para registrar el token');
    } else {
      throw Exception('No se pudo registrar el token FCM');
    }
  }
}