// Importación de la librería fundamental de Flutter para capacidades reactivas como ChangeNotifier
import 'package:flutter/foundation.dart';

// Importaciones de los modelos de datos que representan las entidades del negocio
import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';

// Importaciones de los servicios encargados de la comunicación con la API o base de datos
import 'package:clinic_movil/services/appointment_service.dart';
import 'package:clinic_movil/services/doctor_service.dart';
import 'package:clinic_movil/services/patient_service.dart';

/// ViewModel encargado de gestionar el estado y la lógica de negocio del módulo de citas.
/// Utiliza [ChangeNotifier] para notificar de forma reactiva a las vistas ante cualquier cambio de estado.
class AppointmentsViewModel extends ChangeNotifier {
  // Instancias privadas de los servicios requeridos para las operaciones CRUD y catálogos
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();

  // Listas reactivas que almacenan los datos recuperados de los servicios
  List<AppointmentModel> appointments = [];
  List<DoctorModel> doctors = [];
  List<PatientModel> patients = [];

  // Banderas de estado para controlar los indicadores visuales de progreso (Spinners)
  bool isLoading = false;
  bool isFormLoading = false;

  // Variable para almacenar y canalizar mensajes de error hacia la interfaz de usuario
  String? errorMessage;

  /// Recupera la lista completa de citas médicas registradas en el sistema.
  Future<void> loadAppointments() async {
    // Activa el estado de carga general y limpia errores previos antes de iniciar la petición
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // Notifica a la UI para renderizar el estado de carga

    try {
      debugPrint('[AppointmentsViewModel] Cargando citas...');
      // Solicitud asíncrona al servicio de citas
      appointments = await _appointmentService.getAll();
      debugPrint('[AppointmentsViewModel] Citas cargadas exitosamente: ${appointments.length}');
    } catch (e) {
      // Captura cualquier excepción, mapea el error y vacía la lista para evitar datos corruptos
      errorMessage = e.toString();
      debugPrint('[AppointmentsViewModel] Error al cargar citas: $errorMessage');
      appointments = [];
    } finally {
      // Garantiza la desactivación del estado de carga y actualiza la UI sin importar el resultado
      isLoading = false;
      notifyListeners();
    }
  }

  /// Procesa la creación de una nueva cita médica.
  /// Devuelve [true] si la operación fue exitosa o [false] en caso de fallo.
  Future<bool> createAppointment(AppointmentModel appointment) async {
    // Activa el estado de carga para bloquear interacciones dobles y limpia errores
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AppointmentsViewModel] Creando cita...');
      // Envía los parámetros desglosados del modelo hacia el servicio de inserción
      await _appointmentService.create(
        doctorId: appointment.doctorId,
        patientId: appointment.patientId,
        fecha: appointment.fecha,
        hora: appointment.hora,
        motivo: appointment.motivo,
      );
      debugPrint('[AppointmentsViewModel] Cita creada exitosamente');
      
      // Fuerza la actualización del listado local de citas para reflejar el nuevo registro inmediatamente
      await loadAppointments();
      return true;
    } catch (e) {
      // Registra el error ocurrido en el flujo de creación
      errorMessage = e.toString();
      debugPrint('[AppointmentsViewModel] Error creando la cita: $errorMessage');
      return false;
    } finally {
      // Restablece el estado de carga y notifica los cambios finales
      isLoading = false;
      notifyListeners();
    }
  }

  /// Carga de forma asíncrona los catálogos de doctores y pacientes requeridos para los formularios.
  Future<void> loadFormOptions() async {
    // Activa la bandera de carga específica para los elementos del formulario
    isFormLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[AppointmentsViewModel] Cargando opciones del formulario...');
      // Consume en paralelo/secuencia los servicios de consulta para alimentar los selectores drops
      final loadedDoctors = await _doctorService.getDoctors();
      final loadedPatients = await _patientService.getPatients();

      // Asigna las colecciones recuperadas a las variables de estado global
      doctors = loadedDoctors;
      patients = loadedPatients;
      debugPrint('[AppointmentsViewModel] Opciones cargadas: ${doctors.length} doctores, ${patients.length} pacientes');
    } catch (e) {
      // Captura y gestiona anomalías en la obtención de los catálogos base
      errorMessage = e.toString();
      debugPrint('[AppointmentsViewModel] Error cargando opciones: $errorMessage');
    } finally {
      // Concluye el estado de carga del formulario y actualiza los componentes visuales
      isFormLoading = false;
      notifyListeners();
    }
  }
}