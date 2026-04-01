import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/registration/registration_view_model.dart';

class StepReferralView extends StatefulWidget {
  const StepReferralView({super.key});

  @override
  State<StepReferralView> createState() => _StepReferralViewState();
}

class _StepReferralViewState extends State<StepReferralView> {
  late final TextEditingController _codeCtrl;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegistrationViewModel>().draft;
    _codeCtrl = TextEditingController(text: draft.referralCode);
    _focusNode = FocusNode();
    
    // Ensure regular keyboard focus after transition
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Seni kim davet etti?',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Rivorya yalnızca davet yoluyla katılıma açıktır.\n'
              'Referans kodun olmadan devam edemezsin.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Davet kodu, seni davet eden kişiden gelir',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _codeCtrl,
              focusNode: _focusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text, // Normal keyboard
              textInputAction: TextInputAction.done,
              onChanged: (v) => context
                  .read<RegistrationViewModel>()
                  .updateReferralCode(v.trim()),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'REFERANS KODU',
                hintStyle: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
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
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
