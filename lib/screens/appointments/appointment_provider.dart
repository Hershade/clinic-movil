import 'package:flutter/foundation.dart';
import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';
import 'package:clinic_movil/services/appointment_service.dart';
import 'package:clinic_movil/services/doctor_service.dart';
import 'package:clinic_movil/services/patient_service.dart';

// --- ENUMERACIONES (Opciones predefinidas) ---
// Sirven para no equivocarnos escribiendo texto (ej. escribir 'al' en vez de 'all').
enum AppointmentFilter { all, byPatient, byDoctor }

// Define en qué estado se encuentra la lista de la pantalla en un momento dado.
enum AppointmentListStatus { loading, awaitingSelection, loaded, error }

/// PROVIDER: Maneja la lógica de negocios y el estado de la pantalla de Citas.
/// Al extender de ChangeNotifier, puede usar 'notifyListeners()' para decirle
/// a la pantalla que se vuelva a dibujar cuando algo cambie.
class AppointmentProvider extends ChangeNotifier {
  // --- SERVICIOS ---
  // Son los "mensajeros" que se comunican con tu base de datos o API.
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();

  // --- DATOS (El estado actual de la app) ---
  List<AppointmentModel> appointments = [];
  List<DoctorModel> doctors = [];
  List<PatientModel> patients = [];

  // --- BANDERAS DE CARGA ---
  // Útiles para mostrar círculos de progreso (spinners) en la interfaz.
  bool isLoadingDoctors = false;
  bool isLoadingPatients = false;

  // --- MANEJO DE ERRORES ---
  String? doctorsError;
  String? patientsError;
  String? listError;

  // --- FILTROS SELECCIONADOS ---
  // Por defecto, carga 'todas' las citas y arranca en estado 'loading'.
  AppointmentFilter currentFilter = AppointmentFilter.all;
  AppointmentListStatus listStatus = AppointmentListStatus.loading;

  // Guardan el ID del doctor o paciente que el usuario seleccionó en el Dropdown.
  int? _patientFilterId;
  int? _doctorFilterId;

  // --- FUNCIONES PRINCIPALES ---

  /// Carga los catálogos de Doctores y Pacientes al mismo tiempo (en paralelo).
  /// Esto es más rápido que cargar uno y luego esperar a que termine para cargar el otro.
  Future<void> loadCatalogs() async {
    await Future.wait([loadDoctors(), loadPatients()]);
  }

  /// Descarga la lista de doctores desde el servidor.
  Future<void> loadDoctors() async {
    isLoadingDoctors = true; // Enciende el estado de carga
    doctorsError = null; // Limpia errores previos
    notifyListeners(); // ¡Avisa a la UI que muestre el spinner!

    try {
      final fetched = await _doctorService.getDoctors();

      // TRUCO DE LIMPIEZA: Elimina duplicados usando un Map.
      // Si la base de datos devuelve dos doctores con el mismo ID, un Dropdown de Flutter
      // colapsará y dará error. Esto asegura que cada ID sea único.
      final map = <int, DoctorModel>{};
      for (var d in fetched) {
        map[d.id] = d;
      }
      doctors = map.values.toList(); // Guarda la lista limpia
    } catch (e) {
      doctorsError = e.toString(); // Si hay error, lo guarda para mostrarlo
      doctors = [];
    } finally {
      isLoadingDoctors = false; // Apaga el estado de carga
      notifyListeners(); // ¡Avisa a la UI que ya terminó (con o sin éxito)!
    }
  }

  /// Descarga la lista de pacientes (Misma lógica exacta que loadDoctors)
  Future<void> loadPatients() async {
    isLoadingPatients = true;
    patientsError = null;
    notifyListeners();

    try {
      final fetched = await _patientService.getPatients();
      // Deduplicar por id
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
  /// Útil para borrar la lista de citas mientras el usuario elige un doctor en el Dropdown.
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
      // Usa el filtro que le pasen, o el que ya tiene guardado por defecto
      final effective = filter ?? currentFilter;
      List<AppointmentModel> result;

      // Decide a qué "ruta" del servidor llamar según el filtro
      if (effective == AppointmentFilter.byPatient &&
          _patientFilterId != null) {
        result = await _appointmentService.getByPatient(_patientFilterId!);
      } else if (effective == AppointmentFilter.byDoctor &&
          _doctorFilterId != null) {
        result = await _appointmentService.getByDoctor(_doctorFilterId!);
      } else {
        result = await _appointmentService.getAll();
      }

      appointments = result; // Guarda el resultado
      listStatus = AppointmentListStatus.loaded; // Marca como completado
    } catch (e) {
      listError = e.toString();
      appointments = [];
      listStatus = AppointmentListStatus.error; // Marca como error
    } finally {
      notifyListeners(); // Actualiza la pantalla
    }
  }

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

  /// Crea una nueva cita en el servidor
  Future<void> createAppointment({
    required int doctorId,
    required int patientId,
    required String fecha,
    required String hora,
    required String motivo,
  }) async {
    // 1. Manda a crear la cita a la base de datos
    await _appointmentService.create(
      doctorId: doctorId,
      patientId: patientId,
      fecha: fecha,
      hora: hora,
      motivo: motivo,
    );

    // 2. Vuelve a descargar la lista de citas para que aparezca la nueva
    await loadAppointments();
  }

  /// Actualiza el estado de una cita (ej. cambiarla a 'completada' o 'cancelada')
  Future<void> updateAppointmentStatus(int id, String estado) async {
    try {
      // 1. Envía la actualización al servidor
      final updated = await _appointmentService.updateStatus(
        id: id,
        estado: estado,
      );

      // 2. TRUCO DE CACHÉ LOCAL:
      // En vez de volver a descargar TODAS las citas de la base de datos,
      // busca la cita en la lista actual de la memoria y la reemplaza por la actualizada.
      // Esto hace que la app se sienta instantánea y ahorra datos de internet.
      final idx = appointments.indexWhere((a) => a.id == updated.id);
      if (idx != -1) {
        appointments[idx] = updated; // Reemplaza la vieja por la nueva
      }
      notifyListeners(); // Refresca la pantalla
    } catch (e) {
      rethrow; // Si falla, le pasa el error a la pantalla (para mostrar un SnackBar)
    }
  }

  /// Es solo un atajo para no tener que escribir 'cancelada' manualmente.
  Future<void> cancelAppointment(int id) async {
    await updateAppointmentStatus(id, 'cancelada');
  }
}
