import 'dart:convert';
import '../models/doctor_model.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService = ApiService();

  Future<List<DoctorModel>> getDoctors() async {
    final response = await _apiService.get('/doctors');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => DoctorModel.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else {
      throw Exception('No se pudieron cargar los doctores');
    }
  }
}