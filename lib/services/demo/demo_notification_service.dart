import '../../core/constants/app_constants.dart';
import '../../models/common/base_response.dart';
import '../../models/notification/notification_model.dart';
import '../interfaces/i_notification_service.dart';

class DemoNotificationService implements INotificationService {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      type: NotificationType.newMatch,
      title: 'Yeni Bağlantı!',
      body: 'Ayşe ile eşleştin. Hemen bir mesaj gönder.',
      senderName: 'Ayşe',
      senderPhoto: 'https://i.pravatar.cc/200?img=1',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n2',
      type: NotificationType.message,
      title: 'Yeni Mesaj',
      body: 'Zeynep sana mesaj gönderdi: "Nasılsın?"',
      senderName: 'Zeynep',
      senderPhoto: 'https://i.pravatar.cc/200?img=2',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationModel(
      id: 'n3',
      type: NotificationType.superLike,
      title: 'Süper Beğeni!',
      body: 'Birisi seni süper beğendi. Kim olduğunu merak ediyor musun?',
      senderName: null,
      senderPhoto: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n4',
      type: NotificationType.profileView,
      title: 'Profil Görüntülendi',
      body: 'Profilin 5 kez görüntülendi. Premium\'a geç ve kim olduğunu gör.',
      senderName: null,
      senderPhoto: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n5',
      type: NotificationType.nearbyUser,
      title: 'Yakınında Biri Var!',
      body: 'Deniz şu an 500 metre yakınında. Keşfet\'e bak.',
      senderName: 'Deniz',
      senderPhoto: 'https://i.pravatar.cc/200?img=5',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n6',
      type: NotificationType.reminder,
      title: 'Bağlantılarını Kaçırma',
      body: '3 yeni bağlantın seni bekliyor. Hepsine göz at!',
      senderName: null,
      senderPhoto: null,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n7',
      type: NotificationType.newMatch,
      title: 'Yeni Bağlantı!',
      body: 'Selin ile eşleştin. İlk mesajı sen at!',
      senderName: 'Selin',
      senderPhoto: 'https://i.pravatar.cc/200?img=9',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      isRead: true,
    ),
    NotificationModel(
      id: 'n8',
      type: NotificationType.message,
      title: 'Yeni Mesaj',
      body: 'Elif sana mesaj gönderdi: "Merhaba! 👋"',
      senderName: 'Elif',
      senderPhoto: 'https://i.pravatar.cc/200?img=10',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  @override
  Future<BaseResponse<List<NotificationModel>>> getNotifications(
      {int page = 1}) async {
    await Future.delayed(AppConstants.mediumDelay);
    if (_notifications.isEmpty) {
      return BaseResponse.empty(message: 'Bildirim yok');
    }
    return BaseResponse.success(data: List.unmodifiable(_notifications));
  }

  @override
  Future<BaseResponse<void>> markAsRead(String notificationId) async {
    await Future.delayed(AppConstants.shortDelay);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
    return BaseResponse.success(data: null, message: 'Okundu olarak işaretlendi');
  }

  @override
  Future<BaseResponse<void>> markAllAsRead() async {
    await Future.delayed(AppConstants.shortDelay);
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    return BaseResponse.success(data: null, message: 'Tümü okundu olarak işaretlendi');
  }
}
