import 'package:flutter/foundation.dart';
import '../models/app_notification_model.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  final ValueNotifier<List<AppNotificationModel>> notifications =
      ValueNotifier<List<AppNotificationModel>>([]);

  void addNotification(AppNotificationModel notification) {
    final current = List<AppNotificationModel>.from(notifications.value);
    current.insert(0, notification);
    notifications.value = current;

    unreadCount.value = current.where((n) => !n.isRead).length;
  }

  void markAllAsRead() {
    final current = List<AppNotificationModel>.from(notifications.value);

    for (final item in current) {
      item.isRead = true;
    }

    notifications.value = current;
    unreadCount.value = 0;
  }

  void markAsRead(int index) {
    final current = List<AppNotificationModel>.from(notifications.value);

    if (index >= 0 && index < current.length) {
      current[index].isRead = true;
      notifications.value = current;
      unreadCount.value = current.where((n) => !n.isRead).length;
    }
  }
}