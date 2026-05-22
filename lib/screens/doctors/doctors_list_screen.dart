import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';
import '../../core/theme/app_colors.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  // Servicio de doctores que usa ApiService para gestionar headers y base URL.
  final DoctorService _doctorService = DoctorService();

  // Future que mantiene el estado de la carga de doctores.
  late Future<List<DoctorModel>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    // Inicializa la carga de datos al montar el widget.
    _doctorsFuture = _loadDoctors();
  }

  Future<List<DoctorModel>> _loadDoctors() async {
    // Obtiene la lista de doctores desde el servicio sin manejar el token aquí.
    return _doctorService.getDoctors();
  }

  Future<void> _reloadDoctors() async {
    // Recarga la lista de doctores y actualiza el Future en el estado.
    setState(() {
      _doctorsFuture = _loadDoctors();
    });
    await _doctorsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctores'),
      ),
      body: FutureBuilder<List<DoctorModel>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          // Estado de carga inicial mientras se obtiene la respuesta.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Si hubo un error en la llamada al servicio, muestra la pantalla de error.
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
                      'Ocurrió un error al cargar los doctores',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reloadDoctors,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final doctors = snapshot.data ?? [];

          // Mensaje cuando no se encontraron doctores.
          if (doctors.isEmpty) {
            return const Center(
              child: Text('No hay doctores registrados'),
            );
          }

          return RefreshIndicator(
            onRefresh: _reloadDoctors,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        doctor.id.toString(),
                      ),
                    ),
                    title: Text(doctor.nombre),
                    subtitle: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Especialidad: ${doctor.especialidad}', overflow: TextOverflow.ellipsis),
                          Text('Teléfono: ${doctor.telefono}', overflow: TextOverflow.ellipsis),
                          Text('Correo: ${doctor.correo}', overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      doctor.activo ? Icons.check_circle : Icons.cancel,
                      color: doctor.activo
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}