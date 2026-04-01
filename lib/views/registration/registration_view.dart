import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/registration/registration_view_model.dart';
import 'steps/step_basic_info_view.dart';
import 'steps/step_complete_view.dart';
import 'steps/step_interests_view.dart';
import 'steps/step_professional_view.dart';
import 'steps/step_profile_view.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RegistrationContent();
  }
}

class _RegistrationContent extends StatefulWidget {
  const _RegistrationContent();

  @override
  State<_RegistrationContent> createState() => _RegistrationContentState();
}

class _RegistrationContentState extends State<_RegistrationContent> {
  late final PageController _pageController;
  late final RegistrationViewModel _vm;
  bool _vmInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm = context.read<RegistrationViewModel>();
      _vmInitialized = true;
      _vm.addListener(_onStepChanged);
    });
  }

  void _onStepChanged() {
    if (!mounted) return;

    if (_vm.readyToNavigateHome) {
      _vm.clearNavigationFlag();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageController.animateToPage(
        _vm.stepIndex,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    if (_vmInitialized) _vm.removeListener(_onStepChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(vm),
      body: Column(
        children: [
          _StepProgressBar(currentIndex: vm.stepIndex, total: vm.totalSteps),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StepPhoneView(),
                StepOtpView(),
                StepReferralView(),
                StepIdentityView(),
                StepExpertiseView(),
                StepInterestsView(),
                StepRulesView(),
              ],
            ),
          ),
          _buildNavBar(context, vm),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RegistrationViewModel vm) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: vm.stepIndex > 0
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
              onPressed: vm.previousStep,
            )
          : const SizedBox.shrink(),
      title: Text(_stepTitle(vm.step), style: AppTextStyles.headingSmall),
      centerTitle: true,
    );
  }

  Widget _buildNavBar(BuildContext context, RegistrationViewModel vm) {
    final Color buttonColor;
    switch (vm.step) {
      case RegStep.phone:
      case RegStep.otp:
        buttonColor = AppColors.primary;
        break;
      case RegStep.referral:
      case RegStep.identity:
        buttonColor = AppColors.secondary;
        break;
      case RegStep.expertise:
      case RegStep.interests:
        buttonColor = AppColors.secondaryLight;
        break;
      case RegStep.rules:
        buttonColor = AppColors.accent;
        break;
    }

    final bool isAccentStep = vm.step == RegStep.rules;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: vm.canGoNext
              ? () {
                  FocusScope.of(context).unfocus();
                  vm.nextStep();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            disabledBackgroundColor: AppColors.border,
            foregroundColor: isAccentStep
                ? AppColors.textOnAccent
                : Colors.white,
            disabledForegroundColor: AppColors.textDisabled,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(_nextButtonLabel(vm.step)),
        ),
      ),
    );
  }

  String _stepTitle(RegStep step) {
    switch (step) {
      case RegStep.phone:
        return 'Telefon Doğrulama';
      case RegStep.otp:
        return 'Kod Doğrulama';
      case RegStep.referral:
        return 'Davet Kodu';
      case RegStep.identity:
        return 'Profil Kimliği';
      case RegStep.expertise:
        return 'Kariyer ve Uzmanlık';
      case RegStep.interests:
        return 'İlgi Alanları';
      case RegStep.rules:
        return 'Topluluk Kuralları';
    }
  }

  String _nextButtonLabel(RegStep step) {
    switch (step) {
      case RegStep.phone:
        return 'SMS Gönder';
      case RegStep.otp:
        return 'Doğrula';
      case RegStep.referral:
        return 'Devam Et';
      case RegStep.identity:
        return 'Kimliği Onayla';
      case RegStep.expertise:
        return 'Devam Et';
      case RegStep.interests:
        return 'İlgi Alanlarını Kaydet';
      case RegStep.rules:
        return 'Anladım, Başla';
    }
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.currentIndex, required this.total});

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.xs,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= currentIndex;

          final Color stepColor;
          switch (i) {
            case 0:
            case 1:
              stepColor = AppColors.primary;
              break;
            case 2:
            case 3:
              stepColor = AppColors.secondary;
              break;
            default:
              stepColor = AppColors.accent;
          }

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: i < total - 1 ? AppSpacing.xs : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active ? stepColor : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: stepColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
