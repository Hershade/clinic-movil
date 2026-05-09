import 'package:flutter/material.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctores'),
      ),
      body: const Center(
        child: Text('Listado de pacientes'),
      ),
    );
  }
}