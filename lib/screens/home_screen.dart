import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'doctors/doctors_list_screen.dart';
import 'patients/patients_list_screen.dart';
import 'appointments/appointments_list_screen.dart';
import '../services/notification_service.dart';
import 'notifications/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  
  final NotificationService _notificationService = NotificationService();
  
  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínica App'),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _notificationService.unreadCount,
            builder: (context, count, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    tooltip: 'Notificaciones',
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Módulos principales',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _MenuCard(
            title: 'Doctores',
            subtitle: 'Ver listado de doctores',
            icon: Icons.medical_services_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorsListScreen()),
              );
            },
          ),
          _MenuCard(
            title: 'Pacientes',
            subtitle: 'Ver listado de pacientes',
            icon: Icons.people_alt_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientsListScreen()),
              );
            },
          ),
          _MenuCard(
            title: 'Citas',
            subtitle: 'Ver y gestionar citas',
            icon: Icons.calendar_month_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppointmentsListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
