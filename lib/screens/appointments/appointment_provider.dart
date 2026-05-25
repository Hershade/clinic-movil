import 'package:flutter/foundation.dart';
import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';
import 'package:clinic_movil/services/appointment_service.dart';
import 'package:clinic_movil/services/doctor_service.dart';
import 'package:clinic_movil/services/patient_service.dart';

enum AppointmentFilter { all, byPatient, byDoctor }

enum AppointmentListStatus { loading, awaitingSelection, loaded, error }

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();

  List<AppointmentModel> appointments = [];
  List<DoctorModel> doctors = [];
  List<PatientModel> patients = [];

  bool isLoadingDoctors = false;
  bool isLoadingPatients = false;

  String? doctorsError;
  String? patientsError;
  String? listError;

  AppointmentFilter currentFilter = AppointmentFilter.all;
  AppointmentListStatus listStatus = AppointmentListStatus.loading;

  int? _patientFilterId;
  int? _doctorFilterId;

  Future<void> loadCatalogs() async {
    await Future.wait([loadDoctors(), loadPatients()]);
  }

  Future<void> loadDoctors() async {
    isLoadingDoctors = true;
    doctorsError = null;
    notifyListeners();

    try {
      final fetched = await _doctorService.getDoctors();
      // Deduplicate by id to avoid duplicate items and Dropdown mismatches
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

  Future<void> loadPatients() async {
    isLoadingPatients = true;
    patientsError = null;
    notifyListeners();

    try {
      final fetched = await _patientService.getPatients();
      // Deduplicate by id
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

  void setFilter(AppointmentFilter filter) {
    currentFilter = filter;
    notifyListeners();
  }

  void prepareFilterSelection() {
    listStatus = AppointmentListStatus.awaitingSelection;
    notifyListeners();
  }

  void setPatientFilter(int id) {
    _patientFilterId = id;
    notifyListeners();
  }

  void setDoctorFilter(int id) {
    _doctorFilterId = id;
    notifyListeners();
  }

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

  Future<void> updateAppointmentStatus(int id, String estado) async {
    try {
      final updated = await _appointmentService.updateStatus(id: id, estado: estado);
      // update local cache if present
      final idx = appointments.indexWhere((a) => a.id == updated.id);
      if (idx != -1) {
        appointments[idx] = updated;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelAppointment(int id) async {
    await updateAppointmentStatus(id, 'cancelada');
  }
}
