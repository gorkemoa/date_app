import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/match/match_model.dart';
import '../../viewmodels/matches/matches_view_model.dart';
import '../../viewmodels/notifications/notifications_view_model.dart';
import '../notifications/notifications_view.dart';
import '../shared/components/loading_view.dart';
import '../shared/components/empty_state_view.dart';
import '../shared/components/error_state_view.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({super.key});

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchesViewModel>().loadMatches();
      context.read<NotificationsViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MatchesViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingView(),
      );
    }

    if (vm.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorStateView(
          message: vm.errorMessage,
          onRetry: () => context.read<MatchesViewModel>().loadMatches(),
        ),
      );
    }

    if (vm.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const _ConnectionsHeader(totalCount: 0),
              const Expanded(
                child: EmptyStateView(
                  icon: Icons.people_outline_rounded,
                  title: 'Henüz bağlantın yok',
                  subtitle: 'Keşfet\'ten birini beğen ve bağlantı kur',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Saf yeni bağlantılar (henüz mesaj yok)
    final pureNew = vm.matches
        .where((m) => m.isNew && m.lastMessage == null)
        .toList();
    final conversations = vm.conversations;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ConnectionsHeader(totalCount: vm.matches.length),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (pureNew.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _NewConnectionsRow(connections: pureNew),
                    ),
                  if (conversations.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionLabel(
                        label: 'Mesajlar',
                        count: conversations.length,
                      ),
                    ),
                    SliverList.separated(
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: AppSpacing.xl + 52 + AppSpacing.sm,
                        endIndent: AppSpacing.xl,
                        color: AppColors.border,
                      ),
                      itemBuilder: (_, i) =>
                          _ConversationTile(match: conversations[i]),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxxl),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────
class _ConnectionsHeader extends StatelessWidget {
  const _ConnectionsHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationsViewModel>().unreadCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.base,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bağlantılar', style: AppTextStyles.displayMedium),
              Text(
                totalCount > 0
                    ? '$totalCount bağlantı'
                    : 'Başlamak için keşfet',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _NotificationButton(unreadCount: unreadCount),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Bildirim Butonu
// ──────────────────────────────────────────────
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<NotificationsViewModel>(),
              child: const NotificationsView(),
            ),
          ),
        );
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: unreadCount > 0 ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: unreadCount > 0 ? AppColors.primary : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: unreadCount > 0
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_rounded,
                  size: 18,
                  color: unreadCount > 0
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Bildirimler',
              style: AppTextStyles.labelSmall.copyWith(
                color: unreadCount > 0
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Yeni bağlantılar yatay satırı
// ──────────────────────────────────────────────
class _NewConnectionsRow extends StatelessWidget {
  const _NewConnectionsRow({required this.connections});

  final List<MatchModel> connections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.base,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Yeni Bağlantılar', style: AppTextStyles.labelLarge),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${connections.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: connections.length,
            itemBuilder: (_, i) => _NewConnectionStoryTile(
              match: connections[i],
              onTap: () => _showStories(context, i),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  void _showStories(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: _StoryViewer(
            connections: connections,
            initialIndex: initialIndex,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Story Viewer – Instagram-style tam özel
// ──────────────────────────────────────────────
class _StoryViewer extends StatefulWidget {
  const _StoryViewer({
    required this.connections,
    required this.initialIndex,
  });

  final List<MatchModel> connections;
  final int initialIndex;

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  late int _personIndex;

  // Drag-to-dismiss state
  double _dragOffset = 0.0;

  // Pause state (long press)
  bool _isPaused = false;

  // Reply
  final _replyController = TextEditingController();
  final _replyFocus = FocusNode();

  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _personIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _advance();
      })
      ..forward();

    _replyFocus.addListener(_handleReplyFocus);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _replyController.dispose();
    _replyFocus
      ..removeListener(_handleReplyFocus)
      ..dispose();
    super.dispose();
  }

  void _handleReplyFocus() {
    if (_replyFocus.hasFocus) {
      _progressController.stop();
    } else {
      if (!_isPaused) _progressController.forward();
    }
  }

  void _advance() {
    if (_personIndex < widget.connections.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _dismiss();
    }
  }

  void _retreat() {
    if (_personIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _progressController
        ..reset()
        ..forward();
    }
  }

  void _dismiss() {
    if (mounted) Navigator.of(context).pop();
  }

  void _resetProgress() {
    _progressController.reset();
    if (!_isPaused && !_replyFocus.hasFocus) _progressController.forward();
  }

  void _pause() {
    setState(() => _isPaused = true);
    _progressController.stop();
  }

  void _resume() {
    setState(() => _isPaused = false);
    if (!_replyFocus.hasFocus) _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final fraction = (_dragOffset / (screenH * 0.38)).clamp(0.0, 1.0);
    final bgAlpha = 1.0 - fraction * 0.72;
    final scale = 1.0 - fraction * 0.10;
    final radius = fraction > 0.02 ? 20.0 : 0.0;

    return GestureDetector(
      // Sadece klavye kapalıyken dikey kaydırmaya izin ver
      onVerticalDragUpdate: (d) {
        if (_replyFocus.hasFocus) return;
        final delta = d.primaryDelta ?? 0;
        if (delta > 0) {
          setState(() => _dragOffset += delta);
          _progressController.stop();
        }
      },
      onVerticalDragEnd: (d) {
        if (_replyFocus.hasFocus) return;
        final velocity = d.primaryVelocity ?? 0;
        if (_dragOffset > 110 || velocity > 650) {
          _dismiss();
        } else {
          setState(() => _dragOffset = 0.0);
          if (!_isPaused) _progressController.forward();
        }
      },
      onVerticalDragCancel: () {
        setState(() => _dragOffset = 0.0);
        if (!_isPaused && !_replyFocus.hasFocus) _progressController.forward();
      },
      child: Material(
        color: Colors.black.withValues(alpha: bgAlpha),
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: Transform.scale(
            scale: scale,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: PageView.builder(
                controller: _pageController,
                // Yatay kaydırma açık – dikey drag kendi handler'ında ele alınıyor
                physics: const PageScrollPhysics(),
                onPageChanged: (i) {
                  setState(() => _personIndex = i);
                  _resetProgress();
                },
                itemCount: widget.connections.length,
                itemBuilder: (context, i) => _StoryPage(
                  match: widget.connections[i],
                  progressController: _progressController,
                  onTapLeft: _retreat,
                  onTapRight: _advance,
                  onLongPressStart: _pause,
                  onLongPressEnd: _resume,
                  onClose: _dismiss,
                  replyController: _replyController,
                  replyFocus: _replyFocus,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Tek bir kişinin story sayfası
// ──────────────────────────────────────────────
class _StoryPage extends StatelessWidget {
  const _StoryPage({
    required this.match,
    required this.progressController,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onClose,
    required this.replyController,
    required this.replyFocus,
  });

  final MatchModel match;
  final AnimationController progressController;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onClose;
  final TextEditingController replyController;
  final FocusNode replyFocus;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        // ── 1. Arka plan fotoğrafı ──────────────────
        Positioned.fill(
          child: Image.network(
            match.userPhoto ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.surface),
          ),
        ),

        // ── 2. Üst + alt degrade ────────────────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.62),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.0, 0.22, 0.58, 1.0],
              ),
            ),
          ),
        ),

        // ── 3. Dokunma bölgeleri (sol %35 / sağ %65) ─
        //    HitTestBehavior.opaque: şeffaf alanlarda da hisseder
        //    Sadece tap + long press – yatay drag PageView'a geçer
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                flex: 35,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapLeft,
                  onLongPressStart: (_) => onLongPressStart(),
                  onLongPressEnd: (_) => onLongPressEnd(),
                  child: const SizedBox.expand(),
                ),
              ),
              Expanded(
                flex: 65,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapRight,
                  onLongPressStart: (_) => onLongPressStart(),
                  onLongPressEnd: (_) => onLongPressEnd(),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),

        // ── 4. Progress bar + Header ─────────────────
        SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: AnimatedBuilder(
                  animation: progressController,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progressController.value,
                      backgroundColor: Colors.white.withValues(alpha: 0.28),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 2.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(match.userPhoto ?? ''),
                        radius: 18,
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // İsim + zaman
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          Text(
                            '2 saat önce',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Üç nokta (opsiyonel menü için yer)
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 22,
                        ),
                      ),
                    ),
                    // Kapatma – büyük dokunma alanı
                    GestureDetector(
                      onTap: onClose,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.92),
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── 5. Alt reply bar ─────────────────────────
        //    Klavye açılınca yukarı kayar (viewInsets)
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomInset,
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: bottomInset > 0 ? 8 : bottomPad + 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mesaj alanı
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: replyController,
                      focusNode: replyFocus,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Mesaj gönder...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.52),
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.42)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 1.2),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Kalp
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.favorite_border_rounded,
                        color: Colors.white, size: 28),
                  ),
                ),
                // Gönder
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewConnectionStoryTile extends StatelessWidget {
  const _NewConnectionStoryTile({required this.match, required this.onTap});

  final MatchModel match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Image.network(
                    match.userPhoto!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              match.userName,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Bölüm etiketi
// ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.base,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.labelLarge),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Konuşma satırı
// ──────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.match});

  final MatchModel match;

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    return '${diff.inDays} gün';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceVariant,
                  child: match.userPhoto != null
                      ? Image.network(
                          match.userPhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarFallback(name: match.userName),
                        )
                      : _AvatarFallback(name: match.userName),
                ),
              ),
              if (match.isNew)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          // İsim + mesaj
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      match.userName,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: match.hasUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _timeLabel(match.lastMessageAt),
                      style: AppTextStyles.caption.copyWith(
                        color: match.hasUnread
                            ? AppColors.primary
                            : AppColors.textDisabled,
                        fontWeight: match.hasUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.lastMessage ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: match.hasUnread
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: match.hasUnread
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (match.hasUnread) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${match.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Avatar fallback
// ──────────────────────────────────────────────
class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
