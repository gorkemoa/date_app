import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
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
  late final RegistrationViewModel _vm;
  bool _currentlyWorking = true;

  @override
  void initState() {
    super.initState();
    _vm = context.read<RegistrationViewModel>();
    final d = _vm.draft;
    _currentlyWorking = d.currentlyWorking;
    _titleCtrl = TextEditingController(text: d.jobTitle);
    _companyCtrl = TextEditingController(text: d.company);
    _industryCtrl = TextEditingController(text: d.industry);
    _vm.addListener(_onVmChanged);
  }

  // LinkedIn parse tamamlandığında alanları otomatik doldur
  void _onVmChanged() {
    if (!mounted) return;
    if (_vm.linkedInJustApplied) {
      final d = _vm.draft;
      setState(() => _currentlyWorking = d.currentlyWorking);
      _titleCtrl.text = d.jobTitle;
      _companyCtrl.text = d.company;
      _industryCtrl.text = d.industry;
      _vm.clearLinkedInJustApplied();
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _industryCtrl.dispose();
    super.dispose();
  }

  void _save() {
    _vm.updateProfessional(
      jobTitle: _titleCtrl.text.trim(),
      company: _currentlyWorking ? _companyCtrl.text.trim() : '',
      industry: _industryCtrl.text.trim(),
      currentlyWorking: _currentlyWorking,
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
            AnimatedOpacity(
              opacity: _currentlyWorking ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: AppTextField(
                controller: _companyCtrl,
                hint: 'örn. Trendyol, Getir, Startupınız',
                onChanged: _currentlyWorking ? (_) => _save() : null,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Checkbox: Şu anda çalışmıyorum
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () {
                setState(() {
                  _currentlyWorking = !_currentlyWorking;
                  if (!_currentlyWorking) _companyCtrl.clear();
                });
                _save();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs, horizontal: 2),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: !_currentlyWorking
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: !_currentlyWorking
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: !_currentlyWorking
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 13)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Şu anda çalışmıyorum',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
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
// LinkedIn AI premium yükleme kartı
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: isImported
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.success.withValues(alpha: 0.12),
                    AppColors.success.withValues(alpha: 0.04),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1035),
                    Color(0xFF2D1B69),
                  ],
                ),
          border: Border.all(
            color: isImported
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.primary.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isImported
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: isImported
              ? _ImportedState()
              : _DefaultState(isLoading: isLoading),
        ),
      ),
    );
  }
}

class _DefaultState extends StatelessWidget {
  const _DefaultState({required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // LinkedIn logo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0077B5),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0077B5).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'PDF CV ile Doldur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9A94FF), Color(0xFFF472B6)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'PDF yükle, yapay zeka tüm alanları otomatik doldursun',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isLoading)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
      ],
    );
  }
}

class _ImportedState extends StatelessWidget {
  const _ImportedState();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.success,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PDF CV bağlandı',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.success),
              ),
              const SizedBox(height: 2),
              Text(
                'Bilgiler yapay zeka ile başarıyla aktarıldı',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Icon(Icons.auto_awesome_rounded,
            color: AppColors.success, size: 20),
      ],
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
