import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';

/// COMPONENTE VISUAL: AppointmentCard
/// Es un StatelessWidget porque solo se encarga de "dibujar" datos en la pantalla.
/// No cambia por sí mismo, sino que reacciona a los datos que le pasas.
class AppointmentCard extends StatelessWidget {
  // --- VARIABLES QUE RECIBE ---
  // Recibe la información completa de una sola cita.
  final AppointmentModel appointment;
  // Recibe una función (opcional) que se ejecutará cuando el usuario toque la tarjeta.
  // VoidCallback significa que es una función que no devuelve ningún valor.
  final VoidCallback? onTap;

  // Constructor: Exige que le pases la cita (required) y opcionalmente el onTap.
  const AppointmentCard({super.key, required this.appointment, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Card: Es el contenedor principal que le da ese aspecto de "tarjeta"
    // con un fondo ligeramente elevado y bordes redondeados por defecto.
    return Card(
      // ListTile: Es un widget súper útil de Flutter diseñado específicamente 
      // para hacer filas con un título, un subtítulo y elementos a los lados.
      child: ListTile(
        // --- TÍTULO PRINCIPAL ---
        title: Text(
          // Muestra el nombre del doctor y del paciente separados por un punto (•)
          '${appointment.doctorNombre} • ${appointment.patientNombre}',
          style: const TextStyle(fontWeight: FontWeight.w600), // Texto en semi-negrita
        ),
        
        // --- SUBTÍTULO (Debajo del título) ---
        // Como ListTile normalmente solo acepta un widget de subtítulo, usamos un Column
        // para poder apilar dos textos: el motivo y la fecha/hora.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda
          mainAxisSize: MainAxisSize.min, // Hace que la columna ocupe solo el espacio necesario
          children: [
            Text(appointment.motivo), // Muestra el motivo de la consulta
            const SizedBox(height: 4), // Pequeño espacio de separación
            Text('${appointment.fecha} ${appointment.hora}'), // Muestra fecha y hora juntas
          ],
        ),
        
        // --- TRAILING (Elemento a la derecha del todo) ---
        // Chip: Es el widget nativo de Flutter para hacer "píldoras" o etiquetas visuales.
        trailing: Chip(
          // Lógica del texto: 
          // Si el estado es 'pendiente', escribe 'Pendiente'.
          // Si no, revisa si es 'cancelada' y escribe 'Cancelada'. Si no es ninguna, escribe el estado tal cual.
          label: Text(
            appointment.estado == 'pendiente'
                ? 'Pendiente'
                : (appointment.estado == 'cancelada' ? 'Cancelada' : appointment.estado),
            style: const TextStyle(color: Colors.white), // Texto en color blanco
          ),
          
          // Lógica del color de fondo:
          // Si es 'pendiente' -> Naranja. Si es 'cancelada' -> Rojo. Cualquier otra -> Gris.
          backgroundColor: appointment.estado == 'pendiente'
              ? Colors.orange
              : (appointment.estado == 'cancelada' ? Colors.red : Colors.grey),
        ),
        
        // --- ACCIÓN AL TOCAR ---
        // Asigna la función que recibimos arriba. 
        // Normalmente esto hace un Navigator.push para llevarte a la pantalla de detalles.
        onTap: onTap,
      ),
    );
  }
}