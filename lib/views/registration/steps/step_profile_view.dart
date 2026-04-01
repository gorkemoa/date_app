import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/registration/expertise_item_model.dart';
import '../../../viewmodels/registration/registration_view_model.dart';
import 'expertise_selection_view.dart';

class StepProfileView extends StatefulWidget {
  const StepProfileView({super.key});

  @override
  State<StepProfileView> createState() => _StepProfileViewState();
}

class _StepProfileViewState extends State<StepProfileView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _expertiseSearchCtrl;
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<RegistrationViewModel>();
    final draft = vm.draft;
    _nameCtrl = TextEditingController(text: draft.displayName);
    _bioCtrl = TextEditingController(text: draft.bio);
    _expertiseSearchCtrl = TextEditingController();

    // İlk açılışta varsayılan kategori (Teknoloji) araması tetiklensin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.searchExpertiseIcons('');
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _expertiseSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_isPickerActive) return;
    setState(() => _isPickerActive = true);
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null || !mounted) return;
      context
          .read<RegistrationViewModel>()
          .setPhoto(bytes: file.bytes!, fileName: file.name);
    } finally {
      if (mounted) setState(() => _isPickerActive = false);
    }
  }

  Future<void> _pickCv() async {
    if (_isPickerActive) return;
    setState(() => _isPickerActive = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null || !mounted) return;
      context
          .read<RegistrationViewModel>()
          .setCv(bytes: file.bytes!, fileName: file.name);
    } finally {
      if (mounted) setState(() => _isPickerActive = false);
    }
  }

  Future<void> _connectLinkedIn() async {
    if (_isPickerActive) return;
    setState(() => _isPickerActive = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null || !mounted) return;
      await context
          .read<RegistrationViewModel>()
          .connectLinkedIn(file.bytes!, file.name);
    } finally {
      if (mounted) setState(() => _isPickerActive = false);
    }
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 15),
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final draft = vm.draft;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.base,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Text('Profilini Oluştur', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Seni tanıyalım',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Kimlik ────────────────────────────────────────────
            const _SectionTitle(title: 'Kimlik'),
            const SizedBox(height: AppSpacing.md),

            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: draft.photoBytes != null
                        ? Colors.transparent
                        : AppColors.surfaceVariant,
                    border: Border.all(
                      color: draft.photoBytes != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: draft.photoBytes != null
                      ? ClipOval(
                          child: Image.memory(
                            draft.photoBytes!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.textSecondary,
                          size: 28,
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                'Fotoğraf ekle',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            const _FieldLabel(text: 'Ad *'),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              onChanged: (v) => context
                  .read<RegistrationViewModel>()
                  .updateProfile(displayName: v.trim()),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: _inputDecoration(hint: 'Adın ve soyadın'),
            ),
            const SizedBox(height: AppSpacing.base),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _FieldLabel(text: 'Kısa Bio'),
                Text(
                  '${_bioCtrl.text.length}/120',
                  style: AppTextStyles.caption.copyWith(
                    color: _bioCtrl.text.length >= 110
                        ? AppColors.error
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _bioCtrl,
              maxLines: 3,
              maxLength: 120,
              onChanged: (v) {
                setState(() {});
                context.read<RegistrationViewModel>().updateProfile(bio: v);
              },
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
              decoration: _inputDecoration(
                      hint: 'Kendinle ilgili kısa bir şey...')
                  .copyWith(counterText: ''),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Kariyer ─────────────────────────────────────────
            const _SectionTitle(title: 'Kariyer'),
            const SizedBox(height: AppSpacing.md),

            const _FieldLabel(text: 'CV (PDF)'),
            const SizedBox(height: AppSpacing.xs),
            _UploadTile(
              icon: Icons.description_outlined,
              label: draft.cvFileName ?? 'CV yükle',
              isUploaded: draft.cvFileName != null,
              onTap: _pickCv,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Uzmanlık Alanı ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _FieldLabel(text: 'Uzmanlık Alanları'),
                TextButton.icon(
                  onPressed: () {
                    final vm = context.read<RegistrationViewModel>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: const ExpertiseSelectionView(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('Ekle / Düzenle', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            if (draft.selectedExpertise.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: draft.selectedExpertise
                    .map((e) => _ExpertiseChip(
                          item: e,
                          onDeleted: () => context
                              .read<RegistrationViewModel>()
                              .toggleExpertise(e),
                        ))
                    .toList(),
              ),
            ] else
              GestureDetector(
                onTap: () {
                  final vm = context.read<RegistrationViewModel>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: vm,
                        child: const ExpertiseSelectionView(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Uzmanlık Seçmek İçin Dokun', 
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),

            // ── İlgi Alanları ────────────────────────────────────────
            const _SectionTitle(title: 'İlgi Alanları'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${draft.selectedInterests.length} alan seçildi',
              style: AppTextStyles.caption.copyWith(
                color: draft.selectedInterests.isNotEmpty
                    ? AppColors.success
                    : AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: RegistrationViewModel.availableInterests.map((interest) {
                final selected = draft.selectedInterests.contains(interest);
                return _InterestChip(
                  label: interest,
                  isSelected: selected,
                  onTap: () => context
                      .read<RegistrationViewModel>()
                      .toggleInterest(interest),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── LinkedIn (opsiyonel) ───────────────────────────────────
            const _SectionTitle(title: 'LinkedIn'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Opsiyonel — LinkedIn bağlarsan profilinde rozet gösterilir.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            if (draft.linkedInConnected)
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.success, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LinkedIn Bağlandı ✓',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Profilinde LinkedIn rozeti görünecek',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              _UploadTile(
                icon: Icons.link_rounded,
                label: 'LinkedIn Bağla (PDF ile)',
                isUploaded: false,
                color: AppColors.secondary,
                onTap: vm.linkedInLoading ? null : _connectLinkedIn,
                isLoading: vm.linkedInLoading,
              ),
            if (vm.hasError) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                vm.errorMessage ?? '',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headingMedium),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(child: Divider(color: AppColors.border, height: 1)),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.labelLarge);
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.icon,
    required this.label,
    required this.isUploaded,
    required this.onTap,
    this.color = AppColors.textSecondary,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final bool isUploaded;
  final VoidCallback? onTap;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isUploaded
              ? color.withValues(alpha: 0.06)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isUploaded ? color.withValues(alpha: 0.4) : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUploaded ? Icons.check_circle_outline : icon,
              color: isUploaded ? color : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isUploaded ? color : AppColors.textSecondary,
                  fontWeight: isUploaded ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.secondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpertiseChip extends StatelessWidget {
  const _ExpertiseChip({required this.item, required this.onDeleted});

  final ExpertiseItem item;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border:
            Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.network(
            item.iconUrl,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            placeholderBuilder: (_) =>
                const SizedBox(width: 16, height: 16),
            headers: const {'Accept': 'image/svg+xml'},
          ),
          const SizedBox(width: 6),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.textOnAccent
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
