import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';
import '../../core/theme/app_colors.dart';
import 'create_doctor_screen.dart';

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

  Future<void> _navigateToCreateDoctor() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDoctorScreen(),
      ),
    );

    if (created == true) {
      await _reloadDoctors();
    }
  }

  Future<void> _deleteDoctor(DoctorModel doctor) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar doctor'),
          content: Text('¿Deseas eliminar a ${doctor.nombre}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) {
      return;
    }

    try {
      await _doctorService.deleteDoctor(doctor.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor eliminado correctamente')),
      );
      await _reloadDoctors();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar doctor: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctores'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateDoctor,
        icon: const Icon(Icons.add),
        label: const Text('Agregar doctor'),
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
                    trailing: SizedBox(
                      width: 96,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            doctor.activo ? Icons.check_circle : Icons.cancel,
                            color: doctor.activo ? AppColors.success : AppColors.error,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            tooltip: 'Eliminar doctor',
                            onPressed: () => _deleteDoctor(doctor),
                          ),
                        ],
                      ),
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