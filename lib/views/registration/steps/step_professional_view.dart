import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/registration/registration_view_model.dart';

class StepOtpView extends StatefulWidget {
  const StepOtpView({super.key});

  @override
  State<StepOtpView> createState() => _StepOtpViewState();
}

class _StepOtpViewState extends State<StepOtpView> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focuses = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focuses) f.dispose();
    super.dispose();
  }

  void _onChanged(int i, String v) {
    if (v.isEmpty && i > 0) {
      _focuses[i - 1].requestFocus();
    } else if (v.length == 1 && i < 5) {
      _focuses[i + 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    context.read<RegistrationViewModel>().updateOtp(code);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final phone = vm.draft.phoneNumber;
    final maskedPhone = phone.length >= 4
        ? '*** ${phone.substring(phone.length - 4)}'
        : phone;

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
            const Text('Kodu Girin', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            RichText(
              text: TextSpan(
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: '+90 '),
                  TextSpan(
                    text: maskedPhone,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const TextSpan(text: ' numarasına SMS gönderdik'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 5 ? AppSpacing.sm : 0),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focuses[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      autofocus: i == 0,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => _onChanged(i, v),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Kodu tekrar gönder',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
