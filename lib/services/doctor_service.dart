import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/doctor_model.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService = ApiService();

  Future<List<DoctorModel>> getDoctors() async {
    final response = await _apiService.get('/doctors');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => DoctorModel.fromJson(item)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('No autorizado. Inicia sesión nuevamente.');
    }

    throw Exception('No se pudieron cargar los doctores');
  }

  Future<DoctorModel> createDoctor({
    required String nombre,
    required String especialidad,
    required String telefono,
    required String correo,
  }) async {
    final response = await _apiService.postJson(
      '/doctors',
      {
        'nombre': nombre.trim(),
        'especialidad': especialidad.trim(),
        'telefono': telefono.trim(),
        'correo': correo.trim(),
      },
    );

    debugPrint('CREATE DOCTOR status: ${response.statusCode}');
    debugPrint('CREATE DOCTOR body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DoctorModel.fromJson(data);
    }

    if (response.statusCode == 400) {
      throw Exception('Datos inválidos para crear el doctor: ${response.body}');
    }

    if (response.statusCode == 401) {
      throw Exception('No autorizado. Inicia sesión nuevamente.');
    }

    if (response.statusCode == 409) {
      throw Exception('Ya existe un doctor con esos datos');
    }

    throw Exception('No se pudo crear el doctor');
  }
}