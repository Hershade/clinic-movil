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

  Future<DoctorModel> createDoctor(DoctorModel doctor) async {
    final response = await _apiService.post('/doctors', body: doctor.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DoctorModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else {
      throw Exception('No se pudo crear el doctor');
    }
  }

  Future<void> deleteDoctor(int doctorId) async {
    final response = await _apiService.delete('/doctors/$doctorId');

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else {
      throw Exception('No se pudo eliminar el doctor');
    }
  }
}