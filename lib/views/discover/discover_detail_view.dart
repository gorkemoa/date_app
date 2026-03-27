import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/discover/discover_card_model.dart';

class DiscoverDetailView extends StatelessWidget {
  const DiscoverDetailView({
    super.key,
    required this.card,
    this.activeFilter,
    required this.onConnect,
    required this.onPass,
  });

  final DiscoverCardModel card;
  final String? activeFilter;
  final VoidCallback onConnect;
  final VoidCallback onPass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _PhotoAppBar(card: card),
              SliverToBoxAdapter(
                child: _ProfileContent(
                    card: card, activeFilter: activeFilter),
              ),
              // Space for the fixed bottom bar
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(
              onPass: () {
                onPass();
                Navigator.pop(context);
              },
              onConnect: () {
                onConnect();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Photo sliver app bar
// ──────────────────────────────────────────────
class _PhotoAppBar extends StatelessWidget {
  const _PhotoAppBar({required this.card});

  final DiscoverCardModel card;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            card.primaryPhoto != null
                ? Image.network(
                    card.primaryPhoto!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _DetailPhotoPlaceholder(name: card.name),
                  )
                : _DetailPhotoPlaceholder(name: card.name),

            // Bottom gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.45, 1.0],
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPhotoPlaceholder extends StatelessWidget {
  const _DetailPhotoPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(
        Icons.person,
        size: 80,
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Profile content
// ──────────────────────────────────────────────
class _ProfileContent extends StatelessWidget {
  const _ProfileContent(
      {required this.card, required this.activeFilter});

  final DiscoverCardModel card;
  final String? activeFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name + verified badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  card.nameAndAge,
                  style: AppTextStyles.headingLarge,
                ),
              ),
              if (card.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 13, color: AppColors.info),
                      const SizedBox(width: 3),
                      Text(
                        'Doğrulandı',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // ── Occupation + location ──
          if (card.occupation != null || card.location != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (card.occupation != null) ...[
                  const Icon(Icons.work_outline_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(card.occupation!,
                      style: AppTextStyles.bodySmall),
                ],
                if (card.occupation != null && card.location != null)
                  Text(' · ',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textDisabled)),
                if (card.location != null) ...[
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(card.location!,
                      style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ],

          // ── Compatibility score ──
          if (card.compatibilityScore != null) ...[
            const SizedBox(height: AppSpacing.base),
            _CompatibilityCard(score: card.compatibilityScore!),
          ],

          // ── Bio ──
          if (card.bio != null && card.bio!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Hakkında', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              card.bio!,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.65),
            ),
          ],

          // ── Interests ──
          if (card.interests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text('İlgi Alanları', style: AppTextStyles.labelLarge),
                if (activeFilter != null &&
                    card.interests.contains(activeFilter)) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          AppColors.primary.withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Ortak: $activeFilter',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: card.interests.map((i) {
                final isActive = i == activeFilter;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    i,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Compatibility card
// ──────────────────────────────────────────────
class _CompatibilityCard extends StatelessWidget {
  const _CompatibilityCard({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).toInt();
    final emoji = pct >= 85 ? '🔥' : pct >= 75 ? '⭐' : '💫';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pct% uyum',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.primary),
                ),
                Text(
                  'Ortak ilgi alanlarına göre hesaplandı',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Fixed bottom action bar
// ──────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar(
      {required this.onPass, required this.onConnect});

  final VoidCallback onPass;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.base,
          AppSpacing.xl, AppSpacing.base + bottomPad),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPass,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Geç'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onConnect,
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Bağlan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

