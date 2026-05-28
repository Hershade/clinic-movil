class PatientModel {
  final int id;
  final String nombre;
  final String dpi;
  final String telefono;
  final String correo;
  final String fechaNacimiento;
  final bool activo;

  PatientModel({
    required this.id,
    required this.nombre,
    required this.dpi,
    required this.telefono,
    required this.correo,
    required this.fechaNacimiento,
    required this.activo,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int parsedId;

    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    } else {
      parsedId = 0;
    }

    return PatientModel(
      id: parsedId,
      nombre: json['nombre']?.toString() ?? '',
      dpi: json['dpi']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      fechaNacimiento: json['fecha_nacimiento']?.toString() ?? '',
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dpi': dpi,
      'telefono': telefono,
      'correo': correo,
      'fecha_nacimiento': fechaNacimiento,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}