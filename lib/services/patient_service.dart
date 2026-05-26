import 'dart:convert';

import '../models/patient_model.dart';
import 'api_service.dart';

class PatientService {
  final ApiService _apiService = ApiService();

  Future<List<PatientModel>> getPatients() async {
    final response = await _apiService.get('/patients');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => PatientModel.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else {
      throw Exception('No se pudieron cargar los pacientes');
    }
  }
}
