import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/discover/discover_view_model.dart';
import '../shared/components/empty_state_view.dart';
import '../shared/components/error_state_view.dart';
import '../shared/components/loading_view.dart';

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
            _DiscoverHeader(refresh: vm.timeUntilRefresh),
            _FilterChipsRow(
              filters: vm.availableFilters,
              selected: vm.selectedFilter,
              onSelected: (f) => context.read<DiscoverViewModel>().setFilter(f),
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
              return null;
            },
          ),
        ),
      ],
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
        AppSpacing.xl,
        AppSpacing.base,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
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
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textDisabled,
                    ),
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
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
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
            color: isSelected
                ? AppColors.textOnSecondary
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
