import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/patient_model.dart';
import '../../services/patient_service.dart';
import 'create_patient_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final PatientService _patientService = PatientService();

  late Future<List<PatientModel>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _loadPatients();
  }

  Future<List<PatientModel>> _loadPatients() async {
    final patients = await _patientService.getPatients();
    final bst = PatientBST();

    for (final patient in patients) {
      bst.insert(patient);
    }

    return bst.toSortedList();
  }

  Future<void> _reloadPatients() async {
    setState(() {
      _patientsFuture = _loadPatients();
    });

    await _patientsFuture;
  }

  Future<void> _goToCreatePatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePatientScreen(),
      ),
    );

    if (result != null) {
      await _reloadPatients();
    }
  }

  void _showPatientDetail(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(patient.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${patient.id}'),
              Text('DPI: ${patient.dpi}'),
              Text('Teléfono: ${patient.telefono}'),
              Text('Correo: ${patient.correo}'),
              Text('Fecha de nacimiento: ${patient.fechaNacimiento}'),
              Text('Estado: ${patient.activo ? 'Activo' : 'Inactivo'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            onPressed: _goToCreatePatient,
            icon: const Icon(Icons.add),
            tooltip: 'Crear paciente',
          ),
        ],
      ),
      body: FutureBuilder<List<PatientModel>>(
        future: _patientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ocurrió un error al cargar los pacientes',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reloadPatients,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final patients = snapshot.data ?? [];

          if (patients.isEmpty) {
            return RefreshIndicator(
              onRefresh: _reloadPatients,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No hay pacientes registrados'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reloadPatients,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(patient.id.toString()),
                    ),
                    title: Text(patient.nombre),
                    subtitle: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DPI: ${patient.dpi}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Teléfono: ${patient.telefono}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Correo: ${patient.correo}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      patient.activo ? Icons.check_circle : Icons.cancel,
                      color: patient.activo
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    isThreeLine: true,
                    onTap: () => _showPatientDetail(patient),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreatePatient,
        tooltip: 'Crear paciente',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PatientNode {
  final PatientModel patient;
  PatientNode? left;
  PatientNode? right;

  PatientNode(this.patient);
}

class PatientBST {
  PatientNode? root;

  void insert(PatientModel patient) {
    root = _insert(root, patient);
  }

  PatientNode _insert(PatientNode? node, PatientModel patient) {
    if (node == null) {
      return PatientNode(patient);
    }

    if (patient.id < node.patient.id) {
      node.left = _insert(node.left, patient);
    } else if (patient.id > node.patient.id) {
      node.right = _insert(node.right, patient);
    }

    return node;
  }

  List<PatientModel> toSortedList() {
    final List<PatientModel> patients = [];
    _inOrder(root, patients);
    return patients;
  }

  void _inOrder(PatientNode? node, List<PatientModel> patients) {
    if (node == null) return;

    _inOrder(node.left, patients);
    patients.add(node.patient);
    _inOrder(node.right, patients);
  }
}