import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'appointment_provider.dart';
import 'appointment_card.dart';
import 'package:clinic_movil/core/theme/app_colors.dart';
import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';
import 'appointment_detail_screen.dart';
import 'create_appointment_screen.dart';
import 'package:clinic_movil/screens/widgets/searchable_entity_field.dart';


class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() =>
      _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  DoctorModel? _filterDoctor;
  PatientModel? _filterPatient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AppointmentProvider>();
      await provider.loadCatalogs();
      await provider.loadAppointments(filter: AppointmentFilter.all);
    });
  }

  Future<void> _openCreate() async {
    final provider = context.read<AppointmentProvider>();
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAppointmentScreen(provider: provider),
      ),
    );

    if (created == true && mounted) {
      await context.read<AppointmentProvider>().loadAppointments();
    }
  }

  Future<void> _openDetail(AppointmentModel appointment) async {
    final provider = context.read<AppointmentProvider>();
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

    if (updated == true && mounted) {
      await context.read<AppointmentProvider>().loadAppointments();
    }
  }

  void _onFilterTypeChanged(AppointmentFilter filter) {
    final provider = context.read<AppointmentProvider>();
    provider.setFilter(filter);

    setState(() {
      if (filter != AppointmentFilter.byDoctor) {
        _filterDoctor = null;
      }
      if (filter != AppointmentFilter.byPatient) {
        _filterPatient = null;
      }
    });

    if (filter == AppointmentFilter.all) {
      provider.loadAppointments();
    } else {
      provider.prepareFilterSelection();
    }
  }

  Future<void> _searchByPatient() async {
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
    provider.setPatientFilter(_filterPatient!.id);
    await provider.loadAppointments(filter: AppointmentFilter.byPatient);
  }

  Future<void> _searchByDoctor() async {
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
    provider.setDoctorFilter(_filterDoctor!.id);
    await provider.loadAppointments(filter: AppointmentFilter.byDoctor);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [
          IconButton(
            onPressed: () => provider.loadAppointments(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Nueva cita'),
      ),
      body: Column(
        children: [
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
          Expanded(child: _buildList(provider)),
        ],
      ),
    );
  }

  Widget _buildList(AppointmentProvider provider) {
    if (provider.listStatus == AppointmentListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
