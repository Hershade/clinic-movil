import 'package:flutter/material.dart';
import '../../models/app_notification_model.dart';
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  void _showNotificationDetail(AppNotificationModel item, int index) {
    _notificationService.markAsRead(index);

    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(item.receivedAt);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.body),
            const SizedBox(height: 12),
            Text('ID cita: ${item.data['appointment_id'] ?? 'N/A'}'),
            Text('Paciente: ${item.data['patient_name'] ?? 'N/A'}'),
            Text('Doctor: ${item.data['doctor_name'] ?? 'N/A'}'),
            Text('Motivo: ${item.data['motivo'] ?? 'N/A'}'),
            // Text('Tipo: ${item.data['type'] ?? 'N/A'}'),
            const SizedBox(height: 12),
            Text(
              'Recibida: $fecha',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
                  isThreeLine: true,
                  onTap: () => _showNotificationDetail(item, index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}