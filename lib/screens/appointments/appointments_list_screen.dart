// Importaciones de paquetes externos de Flutter y gestión de estado
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Importaciones de dependencias internas, widgets y controladores del módulo de citas
import 'appointment_provider.dart';
import 'appointment_card.dart';
import 'package:clinic_movil/core/theme/app_colors.dart';

// Importaciones de los modelos de datos de la aplicación
import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';

// Importaciones de las pantallas de flujo secundario (Detalle y Creación)
import 'appointment_detail_screen.dart';
import 'create_appointment_screen.dart';

// Importación de widget personalizado para la selección de entidades con buscador integrado
import 'package:clinic_movil/screens/widgets/searchable_entity_field.dart';

/// Pantalla principal que renderiza el listado de citas médicas disponibles.
/// Ofrece funcionalidades integradas para filtrar por categorías, médicos y pacientes.
class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() =>
      _AppointmentsListScreenState();
}

/// Estado asociado a la pantalla principal de listado de citas médicas.
class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  // Variables locales de estado para almacenar las entidades seleccionadas para el filtrado avanzado
  DoctorModel? _filterDoctor;
  PatientModel? _filterPatient;

  @override
  void initState() {
    super.initState();
    // Registra un callback para ejecutarse inmediatamente después de que el frame actual sea renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AppointmentProvider>();
      // Inicializa la carga asíncrona de los catálogos base (Doctores y Pacientes)
      await provider.loadCatalogs();
      // Solicita de forma inicial la totalidad de las citas registradas en el sistema
      await provider.loadAppointments(filter: AppointmentFilter.all);
    });
  }

  /// Método asíncrono para gestionar el flujo de navegación hacia la creación de una cita.
  Future<void> _openCreate() async {
    final provider = context.read<AppointmentProvider>();
    // Espera el resultado booleano enviado al retornar de la pantalla de creación
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAppointmentScreen(provider: provider),
      ),
    );

    // Si la cita fue creada exitosamente y el widget sigue activo en el árbol, actualiza la lista principal
    if (created == true && mounted) {
      await context.read<AppointmentProvider>().loadAppointments();
    }
  }

  /// Método asíncrono para gestionar la navegación hacia el detalle interactivo de una cita específica.
  Future<void> _openDetail(AppointmentModel appointment) async {
    final provider = context.read<AppointmentProvider>();
    // Espera un indicador booleano en caso de que la cita haya sufrido modificaciones o cancelaciones
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(
          provider: provider,
          appointmentId: appointment.id,
          initialAppointment: appointment,
        ),
      ),
    );

    // Valida la confirmación de cambios y la permanencia del estado en el árbol de componentes
    if (updated == true && mounted) {
      await context.read<AppointmentProvider>().loadAppointments();
    }
  }

  /// Manejador de eventos que procesa el cambio de categoría en la barra de filtros.
  void _onFilterTypeChanged(AppointmentFilter filter) {
    final provider = context.read<AppointmentProvider>();
    // Actualiza el tipo de filtro activo dentro del estado globalizado del Provider
    provider.setFilter(filter);

    // Restablece los filtros específicos locales si la vista cambia de contexto
    setState(() {
      if (filter != AppointmentFilter.byDoctor) {
        _filterDoctor = null;
      }
      if (filter != AppointmentFilter.byPatient) {
        _filterPatient = null;
      }
    });

    // Ejecuta de forma directa la consulta general o prepara la interfaz para una selección específica
    if (filter == AppointmentFilter.all) {
      provider.loadAppointments();
    } else {
      provider.prepareFilterSelection();
    }
  }

  /// Ejecuta el proceso de búsqueda y filtrado de citas vinculadas a un paciente seleccionado.
  Future<void> _searchByPatient() async {
    // Control de flujo para asegurar que exista una selección válida previo al envío
    if (_filterPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un paciente'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<AppointmentProvider>();
    // Aplica el identificador del paciente al filtro global y procesa la solicitud
    provider.setPatientFilter(_filterPatient!.id);
    await provider.loadAppointments(filter: AppointmentFilter.byPatient);
  }

  /// Ejecuta el proceso de búsqueda y filtrado de citas vinculadas a un médico seleccionado.
  Future<void> _searchByDoctor() async {
    // Control de flujo para asegurar que exista una selección válida previo al envío
    if (_filterDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un doctor'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<AppointmentProvider>();
    // Aplica el identificador del doctor al filtro global y procesa la solicitud
    provider.setDoctorFilter(_filterDoctor!.id);
    await provider.loadAppointments(filter: AppointmentFilter.byDoctor);
  }

  @override
  Widget build(BuildContext context) {
    // Enlace reactivo (watch) al proveedor de gestión de datos de las citas
    final provider = context.watch<AppointmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [
          // Acción manual integrada en el AppBar para forzar la actualización del listado
          IconButton(
            onPressed: () => provider.loadAppointments(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      // Botón flotante persistente configurado para el inicio rápido del formulario de creación
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Nueva cita'),
      ),
      body: Column(
        children: [
          // Segmento superior encargado de la lógica y maquetación de los filtros dinámicos
          _FilterBar(
            currentFilter: provider.currentFilter,
            filterDoctor: _filterDoctor,
            filterPatient: _filterPatient,
            doctors: provider.doctors,
            patients: provider.patients,
            isLoadingDoctors: provider.isLoadingDoctors,
            isLoadingPatients: provider.isLoadingPatients,
            onFilterChanged: _onFilterTypeChanged,
            onDoctorSelected: (doctor) {
              setState(() => _filterDoctor = doctor);
            },
            onPatientSelected: (patient) {
              setState(() => _filterPatient = patient);
            },
            onSearchPatient: _searchByPatient,
            onSearchDoctor: _searchByDoctor,
          ),
          // Contenedor flexible adaptativo asignado para renderizar los resultados de la búsqueda
          Expanded(child: _buildList(provider)),
        ],
      ),
    );
  }

  /// Construye modularmente el contenido principal de la pantalla según el estado actual del flujo.
  Widget _buildList(AppointmentProvider provider) {
    // Estado de Carga: Muestra un indicador circular central de progreso
    if (provider.listStatus == AppointmentListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado de Espera: Indica al usuario que debe realizar una selección en los filtros específicos
    if (provider.listStatus == AppointmentListStatus.awaitingSelection) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.currentFilter == AppointmentFilter.byPatient
                ? 'Selecciona un paciente y pulsa "Buscar citas"'
                : 'Selecciona un doctor y pulsa "Buscar citas"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // Estado de Error: Notifica fallos de conectividad o respuesta del servidor con opción de reintento
    if (provider.listStatus == AppointmentListStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                provider.listError ?? 'Error al cargar citas',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => provider.loadAppointments(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Estado Vacío: Renderiza un mensaje descriptivo cuando no existen citas registradas bajo el criterio actual
    if (provider.appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'No hay citas para mostrar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text('Crear cita'),
              ),
            ],
          ),
        ),
      );
    }

    // Estado Exitoso / Listado: Construye el scroll interactivo con soporte nativo de "Deslizar para actualizar"
    return RefreshIndicator(
      onRefresh: () => provider.loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
        itemCount: provider.appointments.length,
        itemBuilder: (context, index) {
          final appointment = provider.appointments[index];
          return AppointmentCard(
            key: ValueKey(appointment.id),
            appointment: appointment,
            onTap: () => _openDetail(appointment),
          );
        },
      ),
    );
  }
}

/// Widget personalizado desacoplado de presentación para la gestión visual del panel de filtrado.
class _FilterBar extends StatelessWidget {
  final AppointmentFilter currentFilter;
  final DoctorModel? filterDoctor;
  final PatientModel? filterPatient;
  final List<DoctorModel> doctors;
  final List<PatientModel> patients;
  final bool isLoadingDoctors;
  final bool isLoadingPatients;
  final ValueChanged<AppointmentFilter> onFilterChanged;
  final ValueChanged<DoctorModel?> onDoctorSelected;
  final ValueChanged<PatientModel?> onPatientSelected;
  final VoidCallback onSearchPatient;
  final VoidCallback onSearchDoctor;

  const _FilterBar({
    required this.currentFilter,
    required this.filterDoctor,
    required this.filterPatient,
    required this.doctors,
    required this.patients,
    required this.isLoadingDoctors,
    required this.isLoadingPatients,
    required this.onFilterChanged,
    required this.onDoctorSelected,
    required this.onPatientSelected,
    required this.onSearchPatient,
    required this.onSearchDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Componente de botones segmentados para la alternancia veloz entre criterios globales
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppointmentFilter>(
              segments: const [
                ButtonSegment(
                  value: AppointmentFilter.all,
                  label: Text('Todas'),
                  icon: Icon(Icons.list_alt),
                ),
                ButtonSegment(
                  value: AppointmentFilter.byPatient,
                  label: Text('Paciente'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: AppointmentFilter.byDoctor,
                  label: Text('Doctor'),
                  icon: Icon(Icons.medical_services_outlined),
                ),
              ],
              selected: {currentFilter},
              onSelectionChanged: (selection) {
                onFilterChanged(selection.first);
              },
            ),
          ),
        ),
        // Despliegue condicional de formularios avanzados en tarjetas flotantes según la opción activa
        if (currentFilter != AppointmentFilter.all)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Interfaz especializada de selección con autocompletado enfocado en Pacientes
                    if (currentFilter == AppointmentFilter.byPatient) ...[
                      SearchableEntityField<PatientModel>(
                        label: 'Paciente',
                        items: patients,
                        selected: filterPatient,
                        displayText: (p) => p.nombre,
                        isLoading: isLoadingPatients,
                        requiredSelection: false,
                        onChanged: onPatientSelected,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onSearchPatient,
                          icon: const Icon(Icons.search),
                          label: const Text('Buscar citas'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                    // Interfaz especializada de selección con autocompletado enfocado en Doctores
                    if (currentFilter == AppointmentFilter.byDoctor) ...[
                      SearchableEntityField<DoctorModel>(
                        label: 'Doctor',
                        items: doctors,
                        selected: filterDoctor,
                        displayText: (d) => d.nombre,
                        isLoading: isLoadingDoctors,
                        requiredSelection: false,
                        onChanged: onDoctorSelected,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onSearchDoctor,
                          icon: const Icon(Icons.search),
                          label: const Text('Buscar citas'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}