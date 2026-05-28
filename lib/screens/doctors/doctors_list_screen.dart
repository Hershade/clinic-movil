import 'package:flutter/material.dart';

import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';
import 'create_doctor_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final DoctorService _doctorService = DoctorService();

  List<DoctorModel> _doctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctors = await _doctorService.getDoctors();

      if (!mounted) return;

      setState(() {
        _doctors = doctors;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _goToCreateDoctor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDoctorScreen(),
      ),
    );

    if (result != null) {
      await _loadDoctors();
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_doctors.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadDoctors,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.medical_services_outlined,
              size: 56,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Center(
              child: Text('No hay doctores registrados'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDoctors,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _doctors.length,
        itemBuilder: (context, index) {
          final doctor = _doctors[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  doctor.nombre.isNotEmpty
                      ? doctor.nombre[0].toUpperCase()
                      : 'D',
                ),
              ),
              title: Text(doctor.nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Especialidad: ${doctor.especialidad}'),
                  Text('Teléfono: ${doctor.telefono}'),
                  Text('Correo: ${doctor.correo}'),
                  Text(
                    doctor.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: doctor.activo ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctores'),
        actions: [
          IconButton(
            onPressed: _goToCreateDoctor,
            icon: const Icon(Icons.add),
            tooltip: 'Crear doctor',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreateDoctor,
        tooltip: 'Crear doctor',
        child: const Icon(Icons.add),
      ),
    );
  }
}