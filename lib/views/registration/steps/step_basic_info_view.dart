import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/registration/registration_view_model.dart';

class StepPhoneView extends StatefulWidget {
  const StepPhoneView({super.key});

  @override
  State<StepPhoneView> createState() => _StepPhoneViewState();
}

class _StepPhoneViewState extends State<StepPhoneView> {
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegistrationViewModel>().draft;
    _phoneCtrl = TextEditingController(text: draft.phoneNumber);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: AppSpacing.xxxl),
            const Text('Telefon Numaranız', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sizi doğrulamak için SMS göndereceğiz',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: const Text(
                      '+90',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autofocus: true,
                      onChanged: (v) =>
                          context.read<RegistrationViewModel>().updatePhone(v),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: '5xx xxx xx xx',
                        hintStyle: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Numaranız yalnızca hesap doğrulama amacıyla kullanılır.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
