import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/registration/expertise_item_model.dart';
import '../../../viewmodels/registration/registration_view_model.dart';
import '../../../widgets/common/safe_svg_picture.dart';

class ExpertiseSelectionView extends StatefulWidget {
  const ExpertiseSelectionView({super.key});

  @override
  State<ExpertiseSelectionView> createState() => _ExpertiseSelectionViewState();
}

class _ExpertiseSelectionViewState extends State<ExpertiseSelectionView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isManualMode = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent * 0.9) {
      final vm = context.read<RegistrationViewModel>();
      if (!vm.expertiseSearchLoading && vm.hasMoreExpertise) {
        vm.searchExpertiseIcons(_searchCtrl.text, isLoadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final draft = vm.draft;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Uzmanlık Alanı Seç',
          style: AppTextStyles.headingMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tamam',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Seçili Uzmanlıklar
          if (draft.selectedExpertise.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.xs,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: draft.selectedExpertise
                    .map(
                      (item) => Chip(
                        label: Text(
                          item.title,
                          style: AppTextStyles.labelSmall,
                        ),
                        avatar: item.iconUrl.isNotEmpty
                            ? SafeSvgPicture.network(
                                item.iconUrl,
                                width: 16,
                                height: 16,
                              )
                            : null,
                        onDeleted: () => vm.toggleExpertise(item),
                        backgroundColor: AppColors.surfaceVariant,
                        deleteIconColor: AppColors.error,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),

          // Arama Alanı
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => vm.setExpertiseSearch(v),
              decoration: InputDecoration(
                hintText: 'Ara veya elle ekle...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          vm.setExpertiseSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isManualMode
                ? _buildManualEntry(vm)
                : _buildResultsList(vm, draft.selectedExpertise),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    RegistrationViewModel vm,
    List<ExpertiseItem> selectedItems,
  ) {
    if (vm.expertiseResults.isEmpty && !vm.expertiseSearchLoading) {
      if (_searchCtrl.text.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Yeteneklerini aramaya başla',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Örn: React, Figma, Python...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Sonuç bulunamadı', style: AppTextStyles.bodyLarge),
            TextButton(
              onPressed: () => setState(() => _isManualMode = true),
              child: const Text('Elle eklemek ister misin?'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      itemCount:
          vm.expertiseResults.length + (vm.expertiseSearchLoading ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == vm.expertiseResults.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary,
              ),
            ),
          );
        }

        final item = vm.expertiseResults[index];
        final isSelected = selectedItems.contains(item);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SafeSvgPicture.network(
            item.iconUrl,
            width: 32,
            height: 32,
            placeholder: Container(
              width: 32,
              height: 32,
              color: AppColors.surfaceVariant,
            ),
          ),
          title: Text(item.title),
          trailing: Icon(
            isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline,
            color: isSelected ? AppColors.secondary : AppColors.textDisabled,
          ),
          onTap: () => vm.toggleExpertise(item),
        );
      },
    );
  }

  Widget _buildManualEntry(RegistrationViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Text(
            'Aradığın uzmanlığı bulamadın mı?\nKendin ekleyebilirsin.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Örn: Web3 Development',
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.add_task_rounded,
                  color: AppColors.secondary,
                ),
                onPressed: () {
                  if (_searchCtrl.text.isNotEmpty) {
                    vm.addManualExpertise(_searchCtrl.text);
                    _searchCtrl.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Uzmanlık eklendi!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    setState(() => _isManualMode = false);
                  }
                },
              ),
            ),
            controller: _searchCtrl,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => setState(() => _isManualMode = false),
            child: const Text('Aramaya Geri Dön'),
          ),
        ],
      ),
    );
  }
}
