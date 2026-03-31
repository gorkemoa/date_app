import '../../models/common/base_response.dart';
import '../../models/notification/notification_model.dart';

abstract interface class INotificationService {
  Future<BaseResponse<List<NotificationModel>>> getNotifications({int page = 1});
  Future<BaseResponse<void>> markAsRead(String notificationId);
  Future<BaseResponse<void>> markAllAsRead();
}
