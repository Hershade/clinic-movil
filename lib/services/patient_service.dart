import 'dart:convert';
import 'package:flutter/foundation.dart';

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

  Future<PatientModel> getPatientById(int id) async {
    final response = await _apiService.get('/patients/$id');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return PatientModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else {
      throw Exception('No se pudo cargar el paciente');
    }
  }

  Future<PatientModel> createPatient({
    required String nombre,
    required String dpi,
    required String telefono,
    required String correo,
    required String fechaNacimiento,
  }) async {
    final response = await _apiService.postJson(
      '/patients',
      {
        'nombre': nombre.trim(),
        'dpi': dpi.trim(),
        'telefono': telefono.trim(),
        'correo': correo.trim(),
        'fecha_nacimiento': fechaNacimiento.trim(),
      },
    );

    debugPrint('CREATE PATIENT status: ${response.statusCode}');
    debugPrint('CREATE PATIENT body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PatientModel.fromJson(data);
    }

    if (response.statusCode == 400) {
      throw Exception('Datos inválidos para crear el paciente: ${response.body}');
    }

    if (response.statusCode == 401) {
      throw Exception('No autorizado. Inicia sesión nuevamente.');
    }

    if (response.statusCode == 409) {
      throw Exception('Ya existe un paciente con esos datos');
    }

    throw Exception('No se pudo crear el paciente');
  }
}