import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/registration/registration_view_model.dart';
import '../../shared/components/app_text_field.dart';

class StepProfessionalView extends StatefulWidget {
  const StepProfessionalView({super.key});

  @override
  State<StepProfessionalView> createState() => _StepProfessionalViewState();
}

class _StepProfessionalViewState extends State<StepProfessionalView> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _industryCtrl;
  late final TextEditingController _bioCtrl;
  late final RegistrationViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<RegistrationViewModel>();
    final d = _vm.draft;
    _titleCtrl = TextEditingController(text: d.jobTitle);
    _companyCtrl = TextEditingController(text: d.company);
    _industryCtrl = TextEditingController(text: d.industry);
    _bioCtrl = TextEditingController(text: d.bio);
    _vm.addListener(_onVmChanged);
  }

  // LinkedIn parse tamamlandığında alanları otomatik doldur
  void _onVmChanged() {
    if (!mounted) return;
    if (_vm.linkedInJustApplied) {
      final d = _vm.draft;
      _titleCtrl.text = d.jobTitle;
      _companyCtrl.text = d.company;
      _industryCtrl.text = d.industry;
      _bioCtrl.text = d.bio;
      _vm.clearLinkedInJustApplied();
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _industryCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    _vm.updateProfessional(
      jobTitle: _titleCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      industry: _industryCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
    );
  }

  Future<void> _pickLinkedInPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    await _vm.parseLinkedInPdf(file.bytes!, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Text('Kariyer Bilgileri',
                style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'İş hayatınızı tanımlayın',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── LinkedIn ile Otomatik Doldur ──
            _LinkedInCard(
              isLoading: vm.linkedInLoading,
              isImported: vm.draft.linkedInImported,
              onTap: vm.linkedInLoading ? null : _pickLinkedInPdf,
            ),

            const SizedBox(height: AppSpacing.xl),

            const _FieldLabel(label: 'Ünvan / Pozisyon *'),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _titleCtrl,
              hint: 'örn. Senior Yazılım Mühendisi',
              onChanged: (_) => _save(),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.base),

            const _FieldLabel(label: 'Şirket'),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _companyCtrl,
              hint: 'örn. Trendyol, Getir, Startupınız',
              onChanged: (_) => _save(),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.base),

            const _FieldLabel(label: 'Sektör'),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _industryCtrl,
              hint: 'örn. Teknoloji, E-ticaret, Finans',
              onChanged: (_) => _save(),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.base),

            const _FieldLabel(label: 'Hakkınızda'),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _bioCtrl,
              hint: 'Kendinizi kısaca tanıtın...',
              maxLines: 4,
              onChanged: (_) => _save(),
              keyboardType: TextInputType.multiline,
            ),

            if (vm.hasError) ...[
              const SizedBox(height: AppSpacing.sm),
              _LinkedInErrorBanner(message: vm.errorMessage ?? ''),
            ],

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// LinkedIn yükleme kartı
// ──────────────────────────────────────────────
class _LinkedInCard extends StatelessWidget {
  const _LinkedInCard({
    required this.isLoading,
    required this.isImported,
    required this.onTap,
  });

  final bool isLoading;
  final bool isImported;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSuccess = isImported;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isSuccess
              ? AppColors.success.withValues(alpha: 0.06)
              : const Color(0xFFF0EEFF),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSuccess
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            _LinkedInLogo(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSuccess
                        ? '✓  LinkedIn CV bağlandı'
                        : 'LinkedIn CV ile Otomatik Doldur',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSuccess ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSuccess
                        ? 'Bilgiler başarıyla aktarıldı'
                        : 'PDF dosyanizi yukleyin, alanlar otomatik dolsun',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            else if (isSuccess)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 22)
            else
              const Icon(Icons.upload_file_outlined,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _LinkedInLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF0077B5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Center(
        child: Text(
          'in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.labelMedium);
  }
}

class _LinkedInErrorBanner extends StatelessWidget {
  const _LinkedInErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.swipePass.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 14, color: AppColors.swipePass),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.swipePass)),
          ),
        ],
      ),
    );
  }
}
