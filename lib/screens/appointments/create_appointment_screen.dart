import 'package:flutter/material.dart';

import 'package:clinic_movil/core/theme/app_colors.dart';
import 'package:clinic_movil/utils/date_format_utils.dart';
import 'package:clinic_movil/models/doctor_model.dart';
import 'package:clinic_movil/models/patient_model.dart';
import 'package:clinic_movil/screens/appointments/appointment_provider.dart';
import 'package:clinic_movil/screens/widgets/searchable_entity_field.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final AppointmentProvider provider;

  const CreateAppointmentScreen({super.key, required this.provider});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();

  DoctorModel? _selectedDoctor;
  PatientModel? _selectedPatient;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.loadCatalogs();
    });
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  String _doctorLabel(DoctorModel doctor) {
    final prefix = doctor.nombre.toLowerCase().startsWith('dr')
        ? ''
        : 'Dr. ';
    return '$prefix${doctor.nombre}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un doctor'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un paciente'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.provider.createAppointment(
            doctorId: _selectedDoctor!.id,
            patientId: _selectedPatient!.id,
            fecha: DateFormatUtils.formatDate(_selectedDate!),
            hora: DateFormatUtils.formatTime(_selectedTime!),
            motivo: _motivoController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita creada correctamente'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                FormField<DateTime>(
                  validator: (_) => _selectedDate == null ? 'Selecciona una fecha' : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _pickDate();
                          field.didChange(_selectedDate);
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
                FormField<TimeOfDay>(
                  validator: (_) => _selectedTime == null ? 'Selecciona una hora' : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          await _pickTime();
                          field.didChange(_selectedTime);
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
