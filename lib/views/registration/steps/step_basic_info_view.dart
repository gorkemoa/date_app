import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/registration/registration_view_model.dart';
import '../../shared/components/app_text_field.dart';

class StepBasicInfoView extends StatefulWidget {
  const StepBasicInfoView({super.key});

  @override
  State<StepBasicInfoView> createState() => _StepBasicInfoViewState();
}

class _StepBasicInfoViewState extends State<StepBasicInfoView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _yearCtrl;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegistrationViewModel>().draft;
    _nameCtrl = TextEditingController(text: draft.fullName);
    _yearCtrl = TextEditingController(
        text: draft.birthYear?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final vm = context.read<RegistrationViewModel>();
    vm.updateBasicInfo(
      fullName: _nameCtrl.text.trim(),
      birthYear: int.tryParse(_yearCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Text('Merhaba! 👋', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Seni biraz tanıyalım',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const _FieldLabel(label: 'Ad Soyad'),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _nameCtrl,
              hint: 'Adınız ve Soyadınız',
              onChanged: (_) => _save(),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            const _FieldLabel(label: 'Doğum Yılı'),
            const SizedBox(height: AppSpacing.xs),
            AppTextField(
              controller: _yearCtrl,
              hint: 'örn. 1995',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hesabınız yalnızca 18 yaş ve üzeri kullanıcılara açıktır.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textDisabled),
            ),
          ],
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
    return Text(
      label,
      style: AppTextStyles.labelMedium,
    );
  }
}
