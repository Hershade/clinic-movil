import 'package:flutter/foundation.dart';
import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';
import 'package:clinic_movil/services/appointment_service.dart';
import 'package:clinic_movil/services/doctor_service.dart';
import 'package:clinic_movil/services/patient_service.dart';

// --- ENUMERACIONES (Opciones predefinidas) ---
enum AppointmentFilter { all, byPatient, byDoctor }

// Define en qué estado se encuentra la lista de la pantalla en un momento dado.
enum AppointmentListStatus { loading, awaitingSelection, loaded, error }

/// PROVIDER: Maneja la lógica de negocios y el estado de la pantalla de Citas.
class AppointmentProvider extends ChangeNotifier {
  // --- SERVICIOS ---
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();

  // --- DATOS ---
  List<AppointmentModel> appointments = [];
  List<DoctorModel> doctors = [];
  List<PatientModel> patients = [];

  // --- BANDERAS DE CARGA ---
  bool isLoadingDoctors = false;
  bool isLoadingPatients = false;

  // --- MANEJO DE ERRORES ---
  String? doctorsError;
  String? patientsError;
  String? listError;

  // --- FILTROS SELECCIONADOS ---
  AppointmentFilter currentFilter = AppointmentFilter.all;
  AppointmentListStatus listStatus = AppointmentListStatus.loading;

  int? _patientFilterId;
  int? _doctorFilterId;

  // --- FUNCIONES PRINCIPALES ---

  /// Carga los catálogos de Doctores y Pacientes al mismo tiempo.
  Future<void> loadCatalogs() async {
    await Future.wait([loadDoctors(), loadPatients()]);
  }

  /// Descarga la lista de doctores desde el servidor.
  Future<void> loadDoctors() async {
    isLoadingDoctors = true;
    doctorsError = null;
    notifyListeners();

    try {
      final fetched = await _doctorService.getDoctors();

      // Elimina duplicados usando un Map.
      final map = <int, DoctorModel>{};
      for (var d in fetched) {
        map[d.id] = d;
      }
      doctors = map.values.toList();
    } catch (e) {
      doctorsError = e.toString();
      doctors = [];
    } finally {
      isLoadingDoctors = false;
      notifyListeners();
    }
  }

  /// Descarga la lista de pacientes.
  Future<void> loadPatients() async {
    isLoadingPatients = true;
    patientsError = null;
    notifyListeners();

    try {
      final fetched = await _patientService.getPatients();

      final map = <int, PatientModel>{};
      for (var p in fetched) {
        map[p.id] = p;
      }
      patients = map.values.toList();
    } catch (e) {
      patientsError = e.toString();
      patients = [];
    } finally {
      isLoadingPatients = false;
      notifyListeners();
    }
  }

  // --- CONTROL DE FILTROS ---

  /// Cambia el modo de filtro (Todas, Paciente, Doctor)
  void setFilter(AppointmentFilter filter) {
    currentFilter = filter;
    notifyListeners();
  }

  /// Cambia el estado a "Esperando selección".
  void prepareFilterSelection() {
    listStatus = AppointmentListStatus.awaitingSelection;
    notifyListeners();
  }

  /// Guarda qué paciente específico se seleccionó.
  void setPatientFilter(int id) {
    _patientFilterId = id;
    notifyListeners();
  }

  /// Guarda qué doctor específico se seleccionó.
  void setDoctorFilter(int id) {
    _doctorFilterId = id;
    notifyListeners();
  }

  // --- CARGA Y MANEJO DE CITAS ---

  /// Descarga las citas basándose en el filtro actual.
  Future<void> loadAppointments({AppointmentFilter? filter}) async {
    listStatus = AppointmentListStatus.loading;
    listError = null;
    notifyListeners();

    try {
      final effective = filter ?? currentFilter;
      List<AppointmentModel> result;

      if (effective == AppointmentFilter.byPatient && _patientFilterId != null) {
        result = await _appointmentService.getByPatient(_patientFilterId!);
      } else if (effective == AppointmentFilter.byDoctor && _doctorFilterId != null) {
        result = await _appointmentService.getByDoctor(_doctorFilterId!);
      } else {
        result = await _appointmentService.getAll();
      }

      appointments = result;
      listStatus = AppointmentListStatus.loaded;
    } catch (e) {
      listError = e.toString();
      appointments = [];
      listStatus = AppointmentListStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Obtiene una cita por ID y la sincroniza con la lista local.
  Future<AppointmentModel> fetchAppointmentById(int id) async {
    try {
      final appointment = await _appointmentService.getById(id);

      final index = appointments.indexWhere((a) => a.id == appointment.id);
      if (index >= 0) {
        appointments[index] = appointment;
      } else {
        appointments.add(appointment);
      }

      notifyListeners();
      return appointment;
    } catch (e) {
      rethrow;
    }
  }

  /// Crea una nueva cita en el servidor.
  Future<void> createAppointment({
    required int doctorId,
    required int patientId,
    required String fecha,
    required String hora,
    required String motivo,
  }) async {
    await _appointmentService.create(
      doctorId: doctorId,
      patientId: patientId,
      fecha: fecha,
      hora: hora,
      motivo: motivo,
    );

    await loadAppointments();
  }

  /// Actualiza el estado de una cita.
  Future<void> updateAppointmentStatus(int id, String estado) async {
    try {
      final updated = await _appointmentService.updateStatus(
        id: id,
        estado: estado,
      );

      final idx = appointments.indexWhere((a) => a.id == updated.id);
      if (idx != -1) {
        appointments[idx] = updated;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Atajo para cancelar una cita.
  Future<void> cancelAppointment(int id) async {
    await updateAppointmentStatus(id, 'cancelada');
  }
}