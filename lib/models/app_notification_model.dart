class AppNotificationModel {
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  bool isRead;

  AppNotificationModel({
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
  });
}