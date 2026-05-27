class DoctorModel {
  final int id;
  final String nombre;
  final String especialidad;
  final String telefono;
  final String correo;
  final bool activo;

  DoctorModel({
    required this.id,
    required this.nombre,
    required this.especialidad,
    required this.telefono,
    required this.correo,
    required this.activo,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
<<<<<<< Updated upstream
    return DoctorModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      especialidad: json['specialidad'] ?? '', // error tipografico en la API por lo que en este caso debemos usar specialidad
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      activo: json['activo'] ?? false,
    );
  }
=======
    final rawId = json['id'];
    int parsedId;

    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    } else {
      parsedId = 0;
    }

    final especialidad = (json['specialidad'] ?? json['especialidad'] ?? '').toString();

    return DoctorModel(
      id: parsedId,
      nombre: json['nombre']?.toString() ?? '',
      especialidad: especialidad,
      telefono: json['telefono']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      activo: json['activo'] is bool ? json['activo'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'specialidad': especialidad,
      'telefono': telefono,
      'correo': correo,
      'activo': activo,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
>>>>>>> Stashed changes
}