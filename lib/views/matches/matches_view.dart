import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/match/match_model.dart';
import '../../viewmodels/matches/matches_view_model.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.xs),
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
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          if (totalCount > 0)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
        ],
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
              AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.sm),
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
                    horizontal: AppSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${connections.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: connections.length,
            itemBuilder: (_, i) =>
                _NewConnectionChip(match: connections[i]),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _NewConnectionChip extends StatelessWidget {
  const _NewConnectionChip({required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.base),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: ClipOval(
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
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              match.userName,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
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
          AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.xs),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.labelLarge),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs, vertical: 2),
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
                      color: AppColors.primary,
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
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
          style: AppTextStyles.headingSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
