import '../common/base_response.dart';

enum NotificationType {
  newMatch,
  message,
  profileView,
  superLike,
  nearbyUser,
  reminder,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? senderName;
  final String? senderPhoto;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.senderName,
    this.senderPhoto,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      senderName: senderName,
      senderPhoto: senderPhoto,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

typedef NotificationResponse = BaseResponse<List<NotificationModel>>;
