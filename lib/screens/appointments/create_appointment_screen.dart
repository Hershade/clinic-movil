// Importación del kit de herramientas de diseño material de Flutter
import 'package:flutter/material.dart';

// Importaciones de utilidades globales, temas y modelos requeridos por el módulo
import 'package:clinic_movil/core/theme/app_colors.dart';
import 'package:clinic_movil/utils/date_format_utils.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';
import 'package:clinic_movil/screens/appointments/appointment_provider.dart';
import 'package:clinic_movil/screens/widgets/searchable_entity_field.dart';

/// Pantalla de formulario dedicada a la creación y registro de nuevas citas médicas.
class CreateAppointmentScreen extends StatefulWidget {
  // Proveedor de estado para la gestión y persistencia de las operaciones de citas
  final AppointmentProvider provider;

  const CreateAppointmentScreen({super.key, required this.provider});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

/// Estado lógico y de control de eventos para el formulario de creación de citas.
class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  // Clave global para la identificación, validación y control de estado del formulario
  final _formKey = GlobalKey<FormState>();
  
  // Controlador de texto para capturar el motivo de la consulta médica
  final _motivoController = TextEditingController();

  // Variables de estado locales para almacenar las selecciones del usuario
  DoctorModel? _selectedDoctor;
  PatientModel? _selectedPatient;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  // Bandera de control para evitar solicitudes duplicadas durante el proceso de guardado
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Programación asíncrona de carga de catálogos tras el renderizado del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.loadCatalogs();
    });
  }

  @override
  void dispose() {
    // Liberación del controlador de texto para prevenir fugas de memoria en el dispositivo
    _motivoController.dispose();
    super.dispose();
  }

  /// Normaliza visualmente el nombre del médico añadiendo el prefijo correspondiente si hace falta.
  String _doctorLabel(DoctorModel doctor) {
    final prefix = doctor.nombre.toLowerCase().startsWith('dr')
        ? ''
        : 'Dr. ';
    return '$prefix${doctor.nombre}';
  }

  /// Despliega el selector nativo de fecha limitando el rango desde hoy hasta dos años en el futuro.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    // Actualiza el estado local en caso de que el usuario confirme una fecha válida
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Despliega el selector nativo de hora del sistema de manera interactiva.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    // Actualiza el estado local en caso de que el usuario confirme una hora válida
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// Valida los campos de datos y procesa de forma asíncrona el guardado de la nueva cita médica.
  Future<void> _save() async {
    // Ejecuta las validaciones nativas de los campos de texto integrados en el formulario
    if (!_formKey.currentState!.validate()) return;

    // Validación manual externa para asegurar la selección de una entidad Médico
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un doctor'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validación manual externa para asegurar la selección de una entidad Paciente
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un paciente'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Activa el estado de procesamiento visual
    setState(() => _isSaving = true);

    try {
      // Envía la petición estructurada de creación delegando la persistencia al proveedor
      await widget.provider.createAppointment(
            doctorId: _selectedDoctor!.id,
            patientId: _selectedPatient!.id,
            fecha: DateFormatUtils.formatDate(_selectedDate!),
            hora: DateFormatUtils.formatTime(_selectedTime!),
            motivo: _motivoController.text.trim(),
          );

      // Verificación de seguridad para resguardar operaciones de navegación en hilos asíncronos
      if (!mounted) return;

      // Despliega mensaje emergente de éxito transaccional
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita creada correctamente'),
          backgroundColor: AppColors.success,
        ),
      );

      // Retorna a la pantalla previa enviando una bandera afirmativa de actualización requerida
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      // Sanitiza el mensaje de error capturado y lo proyecta mediante un SnackBar de alerta
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      // Restablece el botón de guardado si la vista permanece activa en el contexto
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reconstruye de manera reactiva la interfaz ante notificaciones de cambio emitidas por el proveedor
    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        final provider = widget.provider;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Crear cita'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Selector con motor de búsqueda y paginación para la asignación del Médico
                SearchableEntityField<DoctorModel>(
                  label: 'Doctor',
                  items: provider.doctors,
                  selected: _selectedDoctor,
                  displayText: _doctorLabel,
                  isLoading: provider.isLoadingDoctors,
                  loadError: provider.doctorsError,
                  onRetry: provider.loadDoctors,
                  onChanged: (value) => setState(() => _selectedDoctor = value),
                ),
                const SizedBox(height: 16),
                
                // Selector con motor de búsqueda y paginación para la asignación del Paciente
                SearchableEntityField<PatientModel>(
                  label: 'Paciente',
                  items: provider.patients,
                  selected: _selectedPatient,
                  displayText: (patient) => patient.nombre,
                  isLoading: provider.isLoadingPatients,
                  loadError: provider.patientsError,
                  onRetry: provider.loadPatients,
                  onChanged: (value) => setState(() => _selectedPatient = value),
                ),
                const SizedBox(height: 16),
                
                // Encapsulamiento especial de fecha para interactuar de forma segura con el motor de validación
                FormField<DateTime>(
                  validator: (_) => _selectedDate == null ? 'Selecciona una fecha' : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _pickDate();
                          field.didChange(_selectedDate); // Propaga el cambio interno al validador del FormField
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha',
                            suffixIcon: const Icon(Icons.calendar_today),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _selectedDate == null ? 'Seleccionar fecha' : DateFormatUtils.displayDate(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Encapsulamiento especial de hora para interactuar de forma segura con el motor de validación
                FormField<TimeOfDay>(
                  validator: (_) => _selectedTime == null ? 'Selecciona una hora' : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _pickTime();
                          field.didChange(_selectedTime); // Propaga el cambio interno al validador del FormField
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Hora',
                            suffixIcon: const Icon(Icons.access_time),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _selectedTime == null ? 'Seleccionar hora' : DateFormatUtils.formatTime(_selectedTime!),
                            style: TextStyle(
                              color: _selectedTime == null ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Caja de texto multilínea para la descripción detallada del síntoma o consulta
                TextFormField(
                  controller: _motivoController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El motivo es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Botón interactivo de guardado; muta a indicador de progreso durante peticiones remotas
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar cita'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}