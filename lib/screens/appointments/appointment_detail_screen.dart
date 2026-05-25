import 'package:flutter/material.dart';
import 'package:clinic_movil/models/appointment_model.dart';
import 'package:clinic_movil/screens/appointments/appointment_provider.dart';

/// Pantalla que muestra los detalles de una cita médica específica.
/// Es un StatefulWidget porque necesita manejar su propio estado local (como el indicador de carga).
class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentProvider provider;
  final int appointmentId;
  final AppointmentModel initialAppointment;

  const AppointmentDetailScreen({
    super.key,
    required this.provider,
    required this.appointmentId,
    required this.initialAppointment,
  });

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  // Variable para controlar si el botón está cargando o no.
  bool _isProcessing = false;

  /// Función para cambiar el estado de la cita (por ejemplo, a "cancelada").
  Future<void> _changeStatus(String estado) async {
    // 1. Muestra el indicador de carga (spinner)
    setState(() => _isProcessing = true);
    
    try {
      // 2. Intenta actualizar el estado usando el provider
      await widget.provider.updateAppointmentStatus(widget.appointmentId, estado);
      
      // IMPORTANTE: Verifica si la pantalla sigue abierta antes de mostrar mensajes
      if (!mounted) return; 
      
      // 3. Muestra mensaje de éxito en la parte inferior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado')),
      );
      
      // 4. Cierra la pantalla y regresa a la anterior pasando 'true' como resultado
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      // En caso de error, muestra un mensaje con el detalle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      // 5. Pase lo que pase (éxito o error), detiene el indicador de carga
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder escucha los cambios del 'provider'.
    // Si el provider se actualiza, esta pantalla se redibuja automáticamente con los datos nuevos.
    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        final provider = widget.provider;
        
        // Busca la cita más reciente en la lista del provider. 
        // Si no la encuentra por alguna razón, usa la cita inicial que se pasó al abrir la pantalla.
        final appointment = provider.appointments.firstWhere(
          (a) => a.id == widget.appointmentId,
          orElse: () => widget.initialAppointment,
        );

        return Scaffold(
          appBar: AppBar(title: const Text('Detalle de cita')),
          // LayoutBuilder permite saber el tamaño disponible de la pantalla para hacer un diseño responsivo
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Center(
                  // ConstrainedBox evita que el contenido se estire demasiado en pantallas grandes (como tablets)
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // Si la pantalla es pequeña, ocupa todo el ancho. Si es grande, el ancho máximo será 720px.
                      maxWidth: constraints.maxWidth < 600 ? constraints.maxWidth : 720
                    ),
                    child: Column(
                      children: [
                        // --- TARJETA PRINCIPAL DE DETALLES ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            // Sombra sutil de la tarjeta
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 2,
                                offset: const Offset(0,2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sección: Doctor
                              Text('Doctor', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(
                                appointment.doctorNombre.isNotEmpty ? appointment.doctorNombre : '—',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              
                              // Sección: Paciente
                              Text('Paciente', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(
                                appointment.patientNombre.isNotEmpty ? appointment.patientNombre : '—',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 16),

                              // Sección: Fecha y Hora (mostradas una al lado de la otra usando Row y Expanded)
                              Row(
                                children: [
                                  // Mitad izquierda: Fecha
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            appointment.fecha.isNotEmpty ? appointment.fecha : '—',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Mitad derecha: Hora
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time, size: 18, color: Colors.grey[700]),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            appointment.hora.isNotEmpty ? appointment.hora : '—',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Sección: Motivo de la consulta (En un recuadro gris clarito)
                              Text('Motivo', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Text(
                                  appointment.motivo.isNotEmpty ? appointment.motivo : '—',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Sección: Insignia (Badge) de Estado
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  // Llama a la función que crea la etiqueta visual de colores
                                  _buildStatusBadge(appointment.estado),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // --- ÁREA DE ACCIONES (BOTONES) ---
                        const SizedBox(height: 20),
                        
                        // Si la cita está pendiente, muestra el botón para cancelar
                        if (appointment.isPendiente) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              // Si está cargando, desactiva el botón (null), si no, ejecuta _changeStatus
                              onPressed: _isProcessing ? null : () => _changeStatus('cancelada'),
                              // Muestra un circulito de carga o el texto del botón dependiendo del estado
                              child: _isProcessing
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Cancelar cita', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ] 
                        // Si la cita ya está cancelada o completada, muestra este texto
                        else ...[
                          const SizedBox(height: 8),
                          Text('No hay acciones disponibles para este estado.', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Función constructora que devuelve la etiqueta (píldora) de colores dependiendo del estado
  Widget _buildStatusBadge(String estado) {
    // Convierte el estado a minúsculas para evitar errores al comparar
    final key = estado.toLowerCase();
    Color background;
    Color textColor = Colors.white;
    String label;

    // Decide el color y texto basado en la palabra del estado
    switch (key) {
      case 'cancelada':
        background = Colors.red;
        label = 'Cancelada';
        break;
      case 'confirmada':
        background = Colors.green;
        label = 'Confirmada';
        break;
      case 'pendiente':
      default: // Si no reconoce el estado, asume que está pendiente
        background = Colors.orange;
        textColor = Colors.black; // Texto negro para que contraste con el naranja
        label = 'Pendiente';
        break;
    }
    // Devuelve el contenedor con forma de píldora redondeada
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
    );
  }
}