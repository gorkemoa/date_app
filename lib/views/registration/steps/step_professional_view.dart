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
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    // Auto-focus with a slight delay to ensure stable keyboard opening
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final vm = context.read<RegistrationViewModel>();
    vm.updateOtp(v);

    // Auto-advance if 6 digits are entered
    if (v.length == 6) {
      vm.nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    final phone = vm.draft.phoneNumber;
    final maskedPhone = phone.length >= 4
        ? '*** ${phone.substring(phone.length - 4)}'
        : phone;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
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
            
            // Hidden TextField to capture input
            Stack(
              children: [
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    height: 1,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      showCursor: false,
                      autofocus: true,
                      onChanged: _onChanged,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  ),
                ),
                // Visual Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final char = _controller.text.length > i ? _controller.text[i] : '';
                    final isActive = _controller.text.length == i;
                    final isFilled = _controller.text.length > i;

                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(right: i < 5 ? AppSpacing.sm : 0),
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive 
                            ? Colors.white 
                            : AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isActive 
                              ? AppColors.primary 
                              : isFilled 
                                ? AppColors.primary.withValues(alpha: 0.4) 
                                : AppColors.border,
                            width: isActive ? 2.5 : 1,
                          ),
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Text(
                          char,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
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
