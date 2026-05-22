import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/app_notification_model.dart';
import 'device_service.dart';
import 'notification_service.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceService _deviceService = DeviceService();
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await requestPermission();
    await printToken();
    listenForegroundMessages();
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Permiso notificaciones: ${settings.authorizationStatus}');
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> printToken() async {
    final token = await getToken();
    debugPrint('FCM TOKEN: $token');
  }

  Future<void> syncTokenToBackend() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      debugPrint('FCM: no se obtuvo token');
      return;
    }

    await _deviceService.registerToken(
      token: token,
      platform: 'android',
    );

    debugPrint('FCM token enviado al backend');
  }

  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notificación recibida en foreground');
      debugPrint('Título: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      final notification = AppNotificationModel(
        title: message.notification?.title ?? 'Sin título',
        body: message.notification?.body ?? 'Sin contenido',
        data: Map<String, dynamic>.from(message.data),
        receivedAt: DateTime.now(),
      );

      _notificationService.addNotification(notification);
    });
  }
}