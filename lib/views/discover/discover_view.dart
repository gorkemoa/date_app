import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/discover/discover_card_model.dart';
import '../../viewmodels/discover/discover_view_model.dart';
import '../shared/components/empty_state_view.dart';
import '../shared/components/error_state_view.dart';
import '../shared/components/loading_view.dart';
import 'discover_detail_view.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoverViewModel>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiscoverViewModel>();

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
          onRetry: () => context.read<DiscoverViewModel>().loadCards(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DiscoverHeader(),
            _FilterChipsRow(
              filters: vm.availableFilters,
              selected: vm.selectedFilter,
              onSelected: (f) =>
                  context.read<DiscoverViewModel>().setFilter(f),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(child: _buildContent(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DiscoverViewModel vm) {
    final filtered = vm.filteredCards;

    if (filtered.isEmpty && vm.selectedFilter != null) {
      return EmptyStateView(
        icon: Icons.filter_list_off_rounded,
        title: '"${vm.selectedFilter!}" ile kimse yok',
        subtitle: 'Farklı bir filtre seçebilirsin',
        actionLabel: 'Filtreyi Temizle',
        onAction: () => context.read<DiscoverViewModel>().setFilter(null),
      );
    }

    if (filtered.isEmpty) {
      return EmptyStateView(
        icon: Icons.explore_outlined,
        title: 'Yeni kişi kalmadı',
        subtitle: 'Biraz sonra tekrar kontrol et',
        actionLabel: 'Yenile',
        onAction: () => context.read<DiscoverViewModel>().loadCards(),
      );
    }

    return CustomScrollView(
      slivers: [
        // ── En uyumlu şeridi (filtre yoksa göster) ──
        if (vm.topMatches.isNotEmpty && vm.selectedFilter == null)
          SliverToBoxAdapter(
            child: _TopMatchesRow(
              cards: vm.topMatches,
              onConnect: (id) =>
                  context.read<DiscoverViewModel>().connect(id),
            ),
          ),

        // ── Ana kart grid'i ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.xs,
            AppSpacing.base,
            AppSpacing.xxxl,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.70,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final card = filtered[i];
              return _DiscoverGridCard(
                key: ValueKey(card.id),
                card: card,
                activeFilter: vm.selectedFilter,
                onTap: () => _openDetail(card, vm),
                onConnect: () =>
                    context.read<DiscoverViewModel>().connect(card.id),
                onPass: () =>
                    context.read<DiscoverViewModel>().pass(card.id),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openDetail(DiscoverCardModel card, DiscoverViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiscoverDetailView(
          card: card,
          activeFilter: vm.selectedFilter,
          onConnect: () => vm.connect(card.id),
          onPass: () => vm.pass(card.id),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────
class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Keşfet', style: AppTextStyles.displayMedium),
              Text(
                'İlgi alanlarına göre insanlar',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
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
              Icons.tune_rounded,
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
// Filter chips strip
// ──────────────────────────────────────────────
class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String? selected;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: [
          _FilterChip(
            label: 'Tümü',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          ...filters.map(
            (f) => _FilterChip(
              label: f,
              isSelected: selected == f,
              onTap: () => onSelected(f),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Top matches horizontal row
// ──────────────────────────────────────────────
class _TopMatchesRow extends StatelessWidget {
  const _TopMatchesRow({
    required this.cards,
    required this.onConnect,
  });

  final List<DiscoverCardModel> cards;
  final void Function(String id) onConnect;

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
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('En Uyumlu', style: AppTextStyles.labelLarge),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${cards.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            itemCount: cards.length,
            itemBuilder: (_, i) => _TopMatchCard(
              card: cards[i],
              onConnect: () => onConnect(cards[i].id),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _TopMatchCard extends StatelessWidget {
  const _TopMatchCard({required this.card, required this.onConnect});

  final DiscoverCardModel card;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final score = card.compatibilityScore;
    final pct = score != null ? '${(score * 100).toInt()}% uyum' : null;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: card.primaryPhoto != null
                    ? NetworkImage(card.primaryPhoto!)
                    : null,
                child: card.primaryPhoto == null
                    ? Text(
                        card.name.isNotEmpty ? card.name[0] : '?',
                        style: AppTextStyles.headingMedium
                            .copyWith(color: AppColors.primary),
                      )
                    : null,
              ),
              if (card.isVerified)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child:
                      const Icon(Icons.check, size: 9, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            card.name,
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          if (pct != null) ...[
            const SizedBox(height: 2),
            Text(
              pct,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_outlined,
                      size: 11, color: Colors.white),
                  SizedBox(width: 3),
                  Text(
                    'Bağlan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 2-column grid card
// ──────────────────────────────────────────────
class _DiscoverGridCard extends StatelessWidget {
  const _DiscoverGridCard({
    super.key,
    required this.card,
    required this.activeFilter,
    required this.onTap,
    required this.onConnect,
    required this.onPass,
  });

  final DiscoverCardModel card;
  final String? activeFilter;
  final VoidCallback onTap;
  final VoidCallback onConnect;
  final VoidCallback onPass;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Fotoğraf ──
              _CardPhoto(url: card.primaryPhoto, name: card.name),

              // ── Gradient overlay ──
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.30, 0.60, 1.0],
                    colors: [
                      Colors.transparent,
                      Color(0x99000000),
                      Color(0xE0000000),
                    ],
                  ),
                ),
              ),

              // ── Verified badge ──
              if (card.isVerified)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child:
                        const Icon(Icons.check, size: 9, color: Colors.white),
                  ),
                ),

              // ── Card content ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.nameAndAge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54)
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (card.occupation != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          card.occupation!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (card.interests.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        _CardInterestChips(
                          interests: card.interests,
                          highlight: activeFilter,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      // ── Action buttons ──
                      Row(
                        children: [
                          // Pass
                          GestureDetector(
                            onTap: onPass,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 15),
                            ),
                          ),
                          const Spacer(),
                          // Connect
                          GestureDetector(
                            onTap: onConnect,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_add_outlined,
                                      size: 11, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text(
                                    'Bağlan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPhoto extends StatelessWidget {
  const _CardPhoto({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _PhotoPlaceholder(name: name),
      );
    }
    return _PhotoPlaceholder(name: name);
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.displayLarge
              .copyWith(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

class _CardInterestChips extends StatelessWidget {
  const _CardInterestChips({required this.interests, this.highlight});

  final List<String> interests;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    // Show highlighted interest first, then fill to max 2 total
    final List<String> shown = [];
    if (highlight != null && interests.contains(highlight)) {
      shown.add(highlight!);
    }
    for (final i in interests) {
      if (shown.length >= 2) break;
      if (!shown.contains(i)) shown.add(i);
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: shown.map((i) {
        final isHighlighted = i == highlight;
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            i,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

