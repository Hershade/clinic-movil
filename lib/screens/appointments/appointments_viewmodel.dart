import 'package:flutter/foundation.dart';

import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';
import 'package:clinic_movil/services/appointment_service.dart';
import 'package:clinic_movil/services/doctor_service.dart';
import 'package:clinic_movil/services/patient_service.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();

  List<AppointmentModel> appointments = [];
  List<DoctorModel> doctors = [];
  List<PatientModel> patients = [];
  bool isLoading = false;
  bool isFormLoading = false;
  String? errorMessage;

  Future<void> loadAppointments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AppointmentsViewModel] Cargando citas...');
      appointments = await _appointmentService.getAll();
      debugPrint('[AppointmentsViewModel] Citas cargadas exitosamente: ${appointments.length}');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[AppointmentsViewModel] Error al cargar citas: $errorMessage');
      appointments = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment(AppointmentModel appointment) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AppointmentsViewModel] Creando cita...');
      await _appointmentService.create(
        doctorId: appointment.doctorId,
        patientId: appointment.patientId,
        fecha: appointment.fecha,
        hora: appointment.hora,
        motivo: appointment.motivo,
      );
      debugPrint('[AppointmentsViewModel] Cita creada exitosamente');
      await loadAppointments();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[AppointmentsViewModel] Error creando la cita: $errorMessage');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFormOptions() async {
    isFormLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AppointmentsViewModel] Cargando opciones del formulario...');
      final loadedDoctors = await _doctorService.getDoctors();
      final loadedPatients = await _patientService.getPatients();

      doctors = loadedDoctors;
      patients = loadedPatients;
      debugPrint('[AppointmentsViewModel] Opciones cargadas: ${doctors.length} doctores, ${patients.length} pacientes');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('[AppointmentsViewModel] Error cargando opciones: $errorMessage');
    } finally {
      isFormLoading = false;
      notifyListeners();
    }
  }
}
