import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/discover/discover_card_model.dart';

class DiscoverDetailView extends StatelessWidget {
  const DiscoverDetailView({
    super.key,
    required this.card,
    this.activeFilter,
    required this.onConnect,
  });

  final DiscoverCardModel card;
  final String? activeFilter;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _DetailPhotoAppBar(card: card),
              SliverToBoxAdapter(
                child: _DetailContent(
                    card: card, activeFilter: activeFilter),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ConnectBar(onConnect: onConnect),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Photo sliver app bar
// ──────────────────────────────────────────────
class _DetailPhotoAppBar extends StatelessWidget {
  const _DetailPhotoAppBar({required this.card});

  final DiscoverCardModel card;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            card.primaryPhoto != null
                ? Image.network(
                    card.primaryPhoto!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _PhotoFallback(name: card.name),
                  )
                : _PhotoFallback(name: card.name),
            // Gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
            // İsim + meslek overlay
            Positioned(
              bottom: AppSpacing.xl,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          card.nameAndAge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (card.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.50),
                                width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  size: 13, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Doğrulandı',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (card.occupation != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.work_outline_rounded,
                            size: 13,
                            color: Color.fromRGBO(255, 255, 255, 0.75)),
                        const SizedBox(width: 4),
                        Text(
                          card.occupation!,
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.75),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (card.location != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13,
                            color: Color.fromRGBO(255, 255, 255, 0.55)),
                        const SizedBox(width: 4),
                        Text(
                          card.location!,
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.30),
            fontSize: 96,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Content body
// ──────────────────────────────────────────────
class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.card, this.activeFilter});

  final DiscoverCardModel card;
  final String? activeFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Networking niyeti bilgi şeridi ──
          if (card.occupation != null || card.distance != null)
            _InfoRow(card: card),

          // ── Hakkında ──
          if (card.bio != null && card.bio!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _SectionCard(
              title: 'Hakkında',
              icon: Icons.person_outline_rounded,
              child: Text(
                card.bio!,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.65),
              ),
            ),
          ],

          // ── İlgi Alanları ──
          if (card.interests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _SectionCard(
              title: 'İlgi Alanları',
              icon: Icons.interests_outlined,
              child: Wrap(
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
                            : AppColors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Text(
                      i,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            isActive ? Colors.white : AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // ── Ortak ilgi alanı varsa vurgula ──
          if (activeFilter != null &&
              card.interests.contains(activeFilter)) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '"$activeFilter" alanında ortak ilginiz var',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Info satırı (meslek + mesafe)
// ──────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.card});

  final DiscoverCardModel card;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          if (card.distance != null) ...[
            _InfoChip(
              icon: Icons.near_me_outlined,
              label: '${card.distance!.toStringAsFixed(1)} km',
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Kart bölümü
// ──────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(title, style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Alt Bağlan çubuğu
// ──────────────────────────────────────────────
class _ConnectBar extends StatelessWidget {
  const _ConnectBar({required this.onConnect});

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
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onConnect,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.base),
            boxShadow: AppShadows.secondaryGlow,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_outlined,
                  size: 18, color: AppColors.textOnSecondary),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Bağlantı İsteği Gönder',
                style: TextStyle(
                  color: AppColors.textOnSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
