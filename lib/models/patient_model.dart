class PatientModel {
  final int id;
  final String nombre;
  final String telefono;
  final String correo;
  final bool activo;

  PatientModel({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.activo,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    dynamic rawId = json['id'];
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
      telefono: json['telefono']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'activo': activo,
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
