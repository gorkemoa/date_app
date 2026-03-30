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

  void _showConnectDialog(BuildContext ctx, DiscoverCardModel card) {
    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => _ConnectDialog(
        card: card,
        onConfirm: () {
          ctx.read<DiscoverViewModel>().connect(card.id);
          Navigator.pop(dialogCtx);
        },
      ),
    );
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
            _DiscoverHeader(refresh: vm.timeUntilRefresh),
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
        subtitle: 'Farklı bir kategori seçebilirsin',
        actionLabel: 'Sıfırla',
        onAction: () => context.read<DiscoverViewModel>().setFilter(null),
      );
    }

    if (filtered.isEmpty) {
      return const EmptyStateView(
        icon: Icons.people_outline_rounded,
        title: 'Herkesle bağlandın!',
        subtitle: 'Yeni grup yarın yenilenir',
      );
    }

    return CustomScrollView(
      slivers: [
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
                isPending: vm.isPendingRequest(card.id),
                onTap: () => _openDetail(card, vm),
                onConnect: () => _showConnectDialog(context, card),
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
          onConnect: () => _showConnectDialog(context, card),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────
class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({required this.refresh});

  final Duration refresh;

  String get _refreshLabel {
    final h = refresh.inHours;
    final m = refresh.inMinutes % 60;
    return '${h}s ${m}dk sonra yenilenir';
  }

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
              const Text('Bugünün Grubu', style: AppTextStyles.displayMedium),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _refreshLabel,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textDisabled),
                  ),
                ],
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
// Filter chips — ortalanmış SingleChildScrollView
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
    final chips = <Widget>[
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
    ];

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(children: chips),
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
          color: isSelected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.textOnSecondary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
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
    required this.isPending,
    required this.onTap,
    required this.onConnect,
  });

  final DiscoverCardModel card;
  final String? activeFilter;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
              // Use Opacity to dim a bit if pending
              Opacity(
                opacity: isPending ? 0.75 : 1.0,
                child: _CardPhoto(url: card.primaryPhoto, name: card.name),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.30, 0.60, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: isPending ? 0.70 : 0.60),
                      Colors.black.withValues(alpha: isPending ? 0.95 : 0.85),
                    ],
                  ),
                ),
              ),
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
                    child: const Icon(Icons.check,
                        size: 9, color: Colors.white),
                  ),
                ),
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
                      _ConnectButton(
                        isPending: isPending,
                        onTap: isPending ? null : onConnect,
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

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.isPending, this.onTap});

  final bool isPending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isPending
              ? AppColors.success.withValues(alpha: 0.25)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(
            color: isPending
                ? AppColors.success.withValues(alpha: 0.60)
                : AppColors.secondary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.check_circle_rounded : Icons.person_add_outlined,
              size: 13,
              color: isPending ? AppColors.success : AppColors.textOnSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              isPending ? 'İstek Gönderildi' : 'Bağlan',
              style: TextStyle(
                color: isPending ? AppColors.success : AppColors.textOnSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Connect confirmation dialog
// ──────────────────────────────────────────────
class _ConnectDialog extends StatelessWidget {
  const _ConnectDialog({
    required this.card,
    required this.onConfirm,
  });

  final DiscoverCardModel card;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.huge),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.secondary, width: 2.5),
              ),
              child: ClipOval(
                child: card.primaryPhoto != null
                    ? Image.network(
                        card.primaryPhoto!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _DialogAvatarFallback(name: card.name),
                      )
                    : _DialogAvatarFallback(name: card.name),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            // İsim
            Text(
              card.name,
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            if (card.occupation != null) ...[
              const SizedBox(height: 4),
              Text(
                card.occupation!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            // Açıklama
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                '${card.name} adlı kişiye bağlantı isteği gönderilecek. Kabul ederse mesajlaşmaya başlayabilirsiniz.',
                style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(AppRadius.base),
                      ),
                      child: const Center(
                        child: Text(
                          'Vazgeç',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.base),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_outlined,
                                size: 15, color: AppColors.textOnSecondary),
                            SizedBox(width: 5),
                            Text(
                              'Bağlan',
                              style: TextStyle(
                                color: AppColors.textOnSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogAvatarFallback extends StatelessWidget {
  const _DialogAvatarFallback({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.headingLarge
              .copyWith(color: AppColors.secondary),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Card photo helper
// ──────────────────────────────────────────────
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
              .copyWith(color: AppColors.secondary.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Interest chips on card
// ──────────────────────────────────────────────
class _CardInterestChips extends StatelessWidget {
  const _CardInterestChips({required this.interests, this.highlight});

  final List<String> interests;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
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
            // Eşleşen ilgi alanı lime ile vurgulanır, diğerleri şeffaf beyaz
            color: isHighlighted
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            i,
            style: TextStyle(
              color: isHighlighted ? AppColors.textOnAccent : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}


