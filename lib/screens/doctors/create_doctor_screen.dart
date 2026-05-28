import 'package:flutter/material.dart';

import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';

class CreateDoctorScreen extends StatefulWidget {
  const CreateDoctorScreen({super.key});

  @override
  State<CreateDoctorScreen> createState() => _CreateDoctorScreenState();
}

class _CreateDoctorScreenState extends State<CreateDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _especialidadController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  final DoctorService _doctorService = DoctorService();

  bool _isLoading = false;
  bool _activo = true;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final DoctorModel doctor = await _doctorService.createDoctor(
        nombre: _nombreController.text.trim(),
        especialidad: _especialidadController.text.trim(),
        telefono: _telefonoController.text.trim(),
        correo: _correoController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor creado correctamente'),
        ),
      );

      Navigator.pop(context, doctor);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _especialidadController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $label es obligatorio';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Correo inválido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear doctor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => _requiredValidator(value, 'nombre'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _especialidadController,
                    decoration: const InputDecoration(
                      labelText: 'Especialidad',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    validator: (value) =>
                        _requiredValidator(value, 'especialidad'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) => _requiredValidator(value, 'teléfono'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _activo,
                    onChanged: (value) {
                      setState(() {
                        _activo = value;
                      });
                    },
                    title: const Text('Activo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar doctor'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}