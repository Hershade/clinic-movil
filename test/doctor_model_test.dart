import 'package:clinic_movil/models/doctor_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DoctorModel', () {
    test('toJson usa el nombre de campo esperado por la API', () {
      final doctor = DoctorModel(
        id: 0,
        nombre: 'Dr. Test',
        especialidad: 'Cardiología',
        telefono: '5551234',
        correo: 'doctor@test.com',
        activo: true,
      );

      expect(doctor.toJson(), containsPair('specialidad', 'Cardiología'));
      expect(doctor.toJson(), containsPair('activo', true));
    });

    test('fromJson acepta el nombre legacy specialidad para compatibilidad', () {
      final doctor = DoctorModel.fromJson({
        'id': '7',
        'nombre': 'Dr. Legacy',
        'specialidad': 'Dermatología',
        'telefono': '5555678',
        'correo': 'legacy@test.com',
        'activo': true,
      });

      expect(doctor.especialidad, 'Dermatología');
    });
  });
}
