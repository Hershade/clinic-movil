import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/app_notification_model.dart';
import '../../models/appointment_model.dart';
import '../../services/notification_service.dart';
import '../appointments/appointment_detail_screen.dart';
import '../appointments/appointment_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final AppointmentProvider _appointmentProvider = AppointmentProvider();

  Future<void> _goToAppointment(AppNotificationModel item, int index) async {
    final rawId = item.data['appointment_id'];
    final appointmentId = int.tryParse(rawId?.toString() ?? '');

    if (appointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el ID de la cita'),
        ),
      );
      return;
    }

    _notificationService.markAsRead(index);

    try {
      final AppointmentModel appointment =
          await _appointmentProvider.fetchAppointmentById(appointmentId);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AppointmentDetailScreen(
            provider: _appointmentProvider,
            appointmentId: appointmentId,
            initialAppointment: appointment,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al abrir la cita: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            onPressed: () {
              _notificationService.markAllAsRead();
            },
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: ValueListenableBuilder<List<AppNotificationModel>>(
        valueListenable: _notificationService.notifications,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No hay notificaciones'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              final fecha = DateFormat('dd/MM/yyyy HH:mm').format(item.receivedAt);

              return Card(
                child: ListTile(
                  leading: Icon(
                    item.isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                  ),
                  title: Text(item.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.body),
                      const SizedBox(height: 4),
                      Text(
                        fecha,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () => _goToAppointment(item, index),
                    child: const Text('Ver cita'),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}