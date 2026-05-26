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
    return DoctorModel(
      id: json['id'],
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
}