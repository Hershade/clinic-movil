class AppointmentModel {
  final int id;
  final int doctorId;
  final int patientId;
  final String doctorNombre;
  final String patientNombre;
  final String fecha;
  final String hora;
  final String motivo;
  final String estado;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorNombre,
    required this.patientNombre,
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.estado,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'];
    final patient = json['patient'] ?? json['paciente'];

    return AppointmentModel(
      id: json['id'] as int? ?? 0,
      doctorId: json['doctor_id'] as int? ??
          (doctor is Map ? doctor['id'] as int? : null) ??
          0,
      patientId: json['patient_id'] as int? ??
          json['paciente_id'] as int? ??
          (patient is Map ? patient['id'] as int? : null) ??
          0,
      doctorNombre: json['doctor_nombre']?.toString() ??
          json['nombre_doctor']?.toString() ??
          (doctor is Map ? doctor['nombre']?.toString() : null) ??
          '',
      patientNombre: json['patient_nombre']?.toString() ??
          json['nombre_paciente']?.toString() ??
          json['paciente_nombre']?.toString() ??
          (patient is Map ? patient['nombre']?.toString() : null) ??
          '',
      fecha: json['fecha']?.toString() ?? '',
      hora: json['hora']?.toString() ?? '',
      motivo: json['motivo']?.toString() ?? '',
      estado: (json['estado']?.toString() ?? 'pendiente').toLowerCase(),
    );
  }

  Map<String, dynamic> toCreateJson() => toUpdateJson();

  Map<String, dynamic> toUpdateJson() {
    return {
      'doctor_id': doctorId,
      'patient_id': patientId,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'doctor_nombre': doctorNombre,
      'patient_nombre': patientNombre,
      'fecha': fecha,
      'hora': hora,
      'motivo': motivo,
      'estado': estado,
    };
  }

  AppointmentModel copyWith({
    int? id,
    int? doctorId,
    int? patientId,
    String? doctorNombre,
    String? patientNombre,
    String? fecha,
    String? hora,
    String? motivo,
    String? estado,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      doctorNombre: doctorNombre ?? this.doctorNombre,
      patientNombre: patientNombre ?? this.patientNombre,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      motivo: motivo ?? this.motivo,
      estado: estado ?? this.estado,
    );
  }

  bool get isPendiente => estado == 'pendiente';
  bool get isCancelada => estado == 'cancelada';
  bool get isCompletada => estado == 'completada';
}
