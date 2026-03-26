class MatchModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isNew;
  final int unreadCount;

  const MatchModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.lastMessage,
    this.lastMessageAt,
    this.isNew = false,
    this.unreadCount = 0,
  });

  bool get hasUnread => unreadCount > 0;
}
