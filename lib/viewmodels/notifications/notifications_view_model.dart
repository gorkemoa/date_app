import '../../models/notification/notification_model.dart';
import '../../services/interfaces/i_notification_service.dart';
import '../base/base_view_model.dart';

class NotificationsViewModel extends BaseViewModel {
  final INotificationService _notificationService;

  NotificationsViewModel({required INotificationService notificationService})
      : _notificationService = notificationService;

  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  /// Grouped by human-readable date label: 'Bugün', 'Dün', 'DD Aaa'
  Map<String, List<NotificationModel>> get groupedByDate {
    final map = <String, List<NotificationModel>>{};
    for (final n in _notifications) {
      final label = _dateLabel(n.createdAt);
      map.putIfAbsent(label, () => []).add(n);
    }
    return map;
  }

  Future<void> loadNotifications() async {
    setLoading();
    final response = await _notificationService.getNotifications();
    if (!response.isSuccess) {
      setError(response.error?.message ?? response.message);
      return;
    }
    if (!response.hasData || response.data!.isEmpty) {
      setEmpty();
      return;
    }
    _notifications = List.of(response.data!);
    setIdle();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Bugün';
    if (d == yesterday) return 'Dün';
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return '${date.day}\n${months[date.month]}';
  }
}
