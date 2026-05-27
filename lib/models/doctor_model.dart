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
    dynamic rawId = json['id'];
    int parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    } else {
      parsedId = 0;
    }

    return DoctorModel(
      id: parsedId,
      nombre: json['nombre'] ?? '',
      especialidad: json['specialidad'] ?? '', // error tipografico en la API por lo que en este caso debemos usar specialidad
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      activo: json['activo'] ?? false,
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
      other is DoctorModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}