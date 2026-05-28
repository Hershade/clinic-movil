import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/appointment_status.dart';
import '../models/appointment_model.dart';
import 'api_service.dart';

class AppointmentService {
  final ApiService _apiService = ApiService();

  Future<List<AppointmentModel>> getAll() async {
    final response = await _apiService.get('/appointments');

    if (response.statusCode == 200) {
      return _parseList(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('No se pudieron cargar las citas');
    }
  }

  Future<AppointmentModel> getById(int id) async {
    final response = await _apiService.get('/appointments/$id');

    if (response.statusCode == 200) {
      return _parseSingle(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else if (response.statusCode == 404) {
      throw Exception('Cita no encontrada');
    } else {
      throw Exception('No se pudo cargar la cita');
    }
  }

  Future<List<AppointmentModel>> getByPatient(int patientId) async {
    final response =
        await _apiService.get('/appointments/patient/$patientId');

    if (response.statusCode == 200) {
      return _parseList(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else if (response.statusCode == 404) {
      return _filterFromAll(
        (appointment) => appointment.patientId == patientId,
      );
    } else {
      throw Exception('No se pudieron cargar las citas del paciente');
    }
  }

  Future<List<AppointmentModel>> getByDoctor(int doctorId) async {
    final response = await _apiService.get('/appointments/doctor/$doctorId');

    if (response.statusCode == 200) {
      return _parseList(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else if (response.statusCode == 404) {
      return _filterFromAll(
        (appointment) => appointment.doctorId == doctorId,
      );
    } else {
      throw Exception('No se pudieron cargar las citas del doctor');
    }
  }

  Future<List<AppointmentModel>> _filterFromAll(
    bool Function(AppointmentModel appointment) test,
  ) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<AppointmentModel> create({
    required int doctorId,
    required int patientId,
    required String fecha,
    required String hora,
    required String motivo,
  }) async {
    final response = await _apiService.postJson(
      '/appointments',
      {
        'doctor_id': doctorId,
        'patient_id': patientId,
        'fecha': fecha,
        'hora': hora,
        'motivo': motivo,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _parseSingle(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else {
      throw Exception(_extractError(response));
    }
  }

  Future<AppointmentModel> update({
    required int id,
    required int doctorId,
    required int patientId,
    required String fecha,
    required String hora,
    required String motivo,
  }) async {
    final body = {
      'doctor_id': doctorId,
      'patient_id': patientId,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
    };

    final response = await _requestWithFallback(
      path: '/appointments/$id',
      body: body,
      methods: const ['PATCH', 'PUT', 'POST'],
    );

    if (response.statusCode == 200) {
      return _parseSingle(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Acceso no autorizado. Por favor inicia sesión de nuevo.');
    } else {
      throw Exception(_extractError(response));
    }
  }

  Future<AppointmentModel> updateStatus({
    required int id,
    required String estado,
  }) async {
    switch (estado) {
      case AppointmentStatus.cancelada:
        return cancel(id);
      case AppointmentStatus.completada:
        return _patchAction(id, 'complete');
      case AppointmentStatus.pendiente:
        return _patchAction(id, 'pendiente');
      default:
        return _patchAction(id, 'complete');
    }
  }

  Future<AppointmentModel> cancel(int id) async {
    return _patchAction(id, 'cancel');
  }

  Future<AppointmentModel> _patchAction(int id, String action) async {
    final paths = [
      '/appointments/$id/$action',
      if (action == 'complete') '/appointments/$id/completar',
      if (action == 'complete') '/appointments/$id/completada',
    ];

    http.Response? lastResponse;

    for (final path in paths) {
      var response = await _apiService.patchJson(path);
      lastResponse = response;

      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await _apiService.postJson(path, {});
        lastResponse = response;
      }

      if (response.statusCode == 200) {
        return _parseSingle(response.body);
      }

      if (response.statusCode == 401) {
        throw Exception(
          'Acceso no autorizado. Por favor inicia sesión de nuevo.',
        );
      }

      if (response.statusCode != 404 && response.statusCode != 405) {
        break;
      }
    }

    if (lastResponse != null &&
        (lastResponse.statusCode == 404 || lastResponse.statusCode == 405)) {
      final fallback = await _apiService.patchJsonWithBody(
        '/appointments/$id',
        {'estado': action == 'complete' ? 'completada' : action},
      );

      if (fallback.statusCode == 200) {
        return _parseSingle(fallback.body);
      }

      throw Exception(_extractError(fallback));
    }

    throw Exception(_extractError(lastResponse!));
  }

  Future<http.Response> _requestWithFallback({
    required String path,
    required Map<String, dynamic> body,
    required List<String> methods,
  }) async {
    http.Response? lastResponse;

    for (final method in methods) {
      final response = switch (method) {
        'PATCH' => await _apiService.patchJsonWithBody(path, body),
        'PUT' => await _apiService.putJson(path, body),
        'POST' => await _apiService.postJson(path, body),
        _ => throw Exception('Método HTTP no soportado: $method'),
      };

      lastResponse = response;

      if (response.statusCode != 404 && response.statusCode != 405) {
        return response;
      }
    }

    return lastResponse!;
  }

  AppointmentModel _parseSingle(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ?? decoded['appointment'] ?? decoded['cita'];
      if (data is Map<String, dynamic>) {
        return AppointmentModel.fromJson(data);
      }
      return AppointmentModel.fromJson(decoded);
    }
    throw Exception('Respuesta inválida del servidor');
  }

  List<AppointmentModel> _parseList(String body) {
    final decoded = jsonDecode(body);

    if (decoded is List) {
      return decoded
          .map((item) => AppointmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] ??
          decoded['appointments'] ??
          decoded['citas'] ??
          decoded['results'];
      if (data is List) {
        return data
            .map(
              (item) => AppointmentModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    }

    return [];
  }

  String _extractError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}

    if (response.statusCode == 405) {
      return 'Método no permitido';
    }

    return 'No se pudo completar la operación';
  }
}
