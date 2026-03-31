import 'package:dynamic_timeline_tile_flutter/dynamic_timeline_tile_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/notification/notification_model.dart';
import '../../viewmodels/notifications/notifications_view_model.dart';
import '../shared/components/empty_state_view.dart';
import '../shared/components/error_state_view.dart';
import '../shared/components/loading_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _NotificationsAppBar(
        hasUnread: vm.hasUnread,
        unreadCount: vm.unreadCount,
        onMarkAllRead: vm.hasUnread
            ? () => context.read<NotificationsViewModel>().markAllAsRead()
            : null,
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(NotificationsViewModel vm) {
    if (vm.isLoading) return const LoadingView();

    if (vm.hasError) {
      return ErrorStateView(
        message: vm.errorMessage,
        onRetry: () => context.read<NotificationsViewModel>().loadNotifications(),
      );
    }

    if (vm.isEmpty) {
      return const EmptyStateView(
        icon: Icons.notifications_none_rounded,
        title: 'Bildirim yok',
        subtitle: 'Yeni eşleşme ve mesajlar burada görünecek',
      );
    }

    final groups = vm.groupedByDate;
    final dateKeys = groups.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base, horizontal: AppSpacing.xs),
      child: Column(
        children: List.generate(dateKeys.length, (index) {
          final dateLabel = dateKeys[index];
          final items = groups[dateLabel] ?? [];

          return MultiDynamicTimelineTile(
            indicatorColor: AppColors.border,
            indicatorWidth: 1.5,
            indicatorRadius: 3,
            crossSpacing: AppSpacing.sm, // Reduced spacing
            mainSpacing: AppSpacing.md,
            starerChild: [
              SizedBox(
                width: 32, // Further reduced width for multi-line date
                child: Text(
                  dateLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
            eventsList: [
              items.map((notification) {
                return EventCard(
                  cardDecoration: BoxDecoration(
                    color: notification.isRead
                        ? AppColors.surface
                        : AppColors.overlayLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.base), // Smaller radius
                    border: Border.all(
                      color: notification.isRead
                          ? AppColors.border
                          : AppColors.primary.withValues(alpha: 0.2),
                    ),
                    boxShadow: notification.isRead
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  verticalCardPadding: AppSpacing.sm,
                  horizontalCardPadding: AppSpacing.md,
                  child: _NotificationTile(
                    notification: notification,
                    onTap: () => context
                        .read<NotificationsViewModel>()
                        .markAsRead(notification.id),
                  ),
                );
              }).toList(),
            ],
          );
        }),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// AppBar
// ──────────────────────────────────────────────
class _NotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _NotificationsAppBar({
    required this.hasUnread,
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  final bool hasUnread;
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 18,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bildirimler', style: AppTextStyles.headingMedium),
          if (hasUnread)
            Text(
              '$unreadCount okunmamış',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.primary, fontSize: 11),
            ),
        ],
      ),
      actions: [
        if (onMarkAllRead != null)
          TextButton(
            onPressed: onMarkAllRead,
            child: Text(
              'Tümünü oku',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Notification Tile
// ──────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationIcon(type: notification.type, photo: notification.senderPhoto),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(left: AppSpacing.xs),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _timeAgo(notification.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays == 1) return 'Dün';
    return '${diff.inDays} gün önce';
  }
}

// ──────────────────────────────────────────────
// Notification Icon
// ──────────────────────────────────────────────
class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type, this.photo});

  final NotificationType type;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photo != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (hasPhoto)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Image.network(
              photo!,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            ),
          )
        else
          _placeholder(),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 1.5),
            ),
            child: Icon(_badgeIcon, size: 11, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(_badgeIcon, size: 20, color: _badgeColor),
    );
  }

  Color get _badgeColor {
    switch (type) {
      case NotificationType.newMatch:
        return AppColors.success;
      case NotificationType.message:
        return AppColors.secondary;
      case NotificationType.superLike:
        return AppColors.primary;
      case NotificationType.profileView:
        return AppColors.warning;
      case NotificationType.nearbyUser:
        return AppColors.accent.withValues(alpha: 1);
      case NotificationType.reminder:
        return AppColors.info;
    }
  }

  IconData get _badgeIcon {
    switch (type) {
      case NotificationType.newMatch:
        return Icons.favorite_rounded;
      case NotificationType.message:
        return Icons.chat_bubble_rounded;
      case NotificationType.superLike:
        return Icons.star_rounded;
      case NotificationType.profileView:
        return Icons.visibility_rounded;
      case NotificationType.nearbyUser:
        return Icons.location_on_rounded;
      case NotificationType.reminder:
        return Icons.notifications_rounded;
    }
  }
}
