import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/doctor_model.dart';
import '../../services/doctor_service.dart';

class CreateDoctorScreen extends StatefulWidget {
  const CreateDoctorScreen({super.key});

  @override
  State<CreateDoctorScreen> createState() => _CreateDoctorScreenState();
}

class _CreateDoctorScreenState extends State<CreateDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _activo = true;
  bool _isSubmitting = false;
  final DoctorService _doctorService = DoctorService();

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final doctor = DoctorModel(
      id: 0,
      nombre: _nameController.text.trim(),
      especialidad: _specialtyController.text.trim(),
      telefono: _phoneController.text.trim(),
      correo: _emailController.text.trim(),
      activo: _activo,
    );

    try {
      await _doctorService.createDoctor(doctor);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el doctor: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear doctor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre del doctor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Especialidad'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la especialidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el correo';
                  }
                  if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(value.trim())) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Activo'),
                value: _activo,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar doctor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
