import 'package:flutter/material.dart';

class AppointmentsListScreen extends StatelessWidget {
  const AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctores'),
      ),
      body: const Center(
        child: Text('Listado de citas'),
      ),
    );
  }
}