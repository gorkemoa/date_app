import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/registration/expertise_item_model.dart';
import '../../../viewmodels/registration/registration_view_model.dart';
import '../../../widgets/common/safe_svg_picture.dart';
import 'expertise_selection_view.dart';

// ─────────────────────────────────────────────────────────────────
// STEP 1: IDENTITY (Photo & Bio)
// ─────────────────────────────────────────────────────────────────
class StepIdentityView extends StatefulWidget {
  const StepIdentityView({super.key});

  @override
  State<StepIdentityView> createState() => _StepIdentityViewState();
}

class _StepIdentityViewState extends State<StepIdentityView> {
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegistrationViewModel>().draft;
    _bioCtrl = TextEditingController(text: draft.bio);
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null || !mounted) return;
    context.read<RegistrationViewModel>().setPhoto(
      bytes: file.bytes!,
      fileName: file.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final draft = vm.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text('Kimlik & Vizyon', style: AppTextStyles.displayMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Profesyonel kimliğini yansıtan bir fotoğraf ve kısa bir vizyon cümlesi belirle.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.massive),

          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceVariant,
                      border: Border.all(
                        color: draft.photoBytes != null
                            ? AppColors.primary
                            : AppColors.border,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: draft.photoBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              draft.photoBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo_rounded,
                            color: AppColors.textSecondary,
                            size: 40,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.massive),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profesyonel Bio', style: AppTextStyles.labelLarge),
              Text(
                '${_bioCtrl.text.length}/140',
                style: AppTextStyles.caption.copyWith(
                  color: _bioCtrl.text.length > 120
                      ? AppColors.error
                      : AppColors.textDisabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _bioCtrl,
            maxLines: 4,
            maxLength: 140,
            textInputAction: TextInputAction.done,
            onChanged: (v) {
              setState(() {});
              context.read<RegistrationViewModel>().updateProfile(bio: v);
            },
            decoration: InputDecoration(
              hintText:
                  'Örn: FinTech alanında ürün tasarımı yapan bir tutkuluyum...',
              hintStyle: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP 2: EXPERTISE (CV & Skills)
// ─────────────────────────────────────────────────────────────────
class StepExpertiseView extends StatefulWidget {
  const StepExpertiseView({super.key});

  @override
  State<StepExpertiseView> createState() => _StepExpertiseViewState();
}

class _StepExpertiseViewState extends State<StepExpertiseView> {
  final TextEditingController _occupationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationViewModel>().loadOccupations();
      _occupationCtrl.text = context.read<RegistrationViewModel>().draft.occupation;
    });
  }

  @override
  void dispose() {
    _occupationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCv(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null || !context.mounted) return;
    context.read<RegistrationViewModel>().setCv(
      bytes: file.bytes!,
      fileName: file.name,
    );
  }

  Future<void> _connectLinkedIn(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null || !context.mounted) return;
    await context.read<RegistrationViewModel>().connectLinkedIn(
      file.bytes!,
      file.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final draft = vm.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Kariyer ve Uzmanlık',
                style: AppTextStyles.displayMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Profesyonel unvanını belirle ve yetkinliklerini kanıtla.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.massive),

          const _SectionHeader(title: 'Meslek / Ünvan'),
          const SizedBox(height: AppSpacing.md),
          
          TextField(
            controller: _occupationCtrl,
            onChanged: (v) => vm.searchOccupations(v),
            decoration: InputDecoration(
              hintText: 'Örn: Yazılım Mühendisi, Tasarımcı...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              suffixIcon: vm.occupationLoading 
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : null,
            ),
          ),

          if (vm.occupationResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: vm.occupationResults.length,
                itemBuilder: (context, index) {
                  final occ = vm.occupationResults[index];
                  return ListTile(
                    title: Text(occ, style: AppTextStyles.bodyMedium),
                    onTap: () {
                      vm.selectOccupation(occ);
                      _occupationCtrl.text = occ;
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: AppSpacing.massive),
          const _SectionHeader(title: 'Yetenek Kartları'),
          const SizedBox(height: AppSpacing.md),

          if (draft.selectedExpertise.isNotEmpty)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: draft.selectedExpertise
                  .map(
                    (e) => _ExpertiseChip(
                      item: e,
                      onDeleted: () => vm.toggleExpertise(e),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: AppSpacing.md),
          _ExpertiseAddButton(
            onTap: () {
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
          ),

          const SizedBox(height: AppSpacing.massive),
          const _SectionHeader(title: 'Belgeler'),
          const SizedBox(height: AppSpacing.md),

          _UploadTile(
            title: 'Özgeçmiş (CV)',
            subtitle: draft.cvFileName ?? 'PDF formatında yükle',
            icon: Icons.description_outlined,
            isCompleted: draft.cvFileName != null,
            onTap: () => _pickCv(context),
          ),
          const SizedBox(height: AppSpacing.base),
          _UploadTile(
            title: 'LinkedIn Bağlantısı',
            subtitle: draft.linkedInConnected
                ? 'Profil rozeti aktif ✓'
                : 'Profilini doğrula (PDF)',
            icon: Icons.link_rounded,
            isCompleted: draft.linkedInConnected,
            onTap: vm.linkedInLoading ? null : () => _connectLinkedIn(context),
            isLoading: vm.linkedInLoading,
            color: const Color(0xFF0077B5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP 3: INTERESTS
// ─────────────────────────────────────────────────────────────────
class StepInterestsView extends StatelessWidget {
  const StepInterestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final draft = vm.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  color: AppColors.accentDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text('İlgi Alanları', style: AppTextStyles.displayMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Ortak noktalarda buluşabileceğin kişileri keşfetmek için en az 3 ilgi alanı seç.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.massive),

          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: RegistrationViewModel.availableInterests.map((interest) {
              final selected = draft.selectedInterests.contains(interest);
              return _InterestChip(
                label: interest,
                isSelected: selected,
                onTap: () => vm.toggleInterest(interest),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.massive),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HELPER COMPONENTS
// ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.textSecondary.withValues(alpha: 0.7),
        letterSpacing: 1.5,
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.onTap,
    this.isLoading = false,
    this.color = AppColors.primary,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isCompleted
              ? color.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isCompleted
                ? color.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? color.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : icon,
                color: isCompleted ? color : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isCompleted
                          ? color.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            else if (!isCompleted)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDisabled,
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpertiseAddButton extends StatelessWidget {
  const _ExpertiseAddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.secondary,
            width: 1,
            style: BorderStyle.none,
          ),
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.05),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Yetenek Seç veya Ekle',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeSvgPicture.network(
            item.iconUrl,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            placeholder: const SizedBox(width: 16, height: 16),
          ),
          const SizedBox(width: 8),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.cancel_rounded,
              size: 16,
              color: AppColors.textDisabled,
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
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentDark],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.accentDark : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected
                ? AppColors.textOnAccent
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
