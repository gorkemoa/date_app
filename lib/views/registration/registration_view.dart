import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/app_enums.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/demo/demo_linkedin_parser_service.dart';
import '../../viewmodels/registration/registration_view_model.dart';
import 'steps/step_basic_info_view.dart';
import 'steps/step_complete_view.dart';
import 'steps/step_interests_view.dart';
import 'steps/step_professional_view.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationViewModel(
        linkedInParser: DemoLinkedInParserService(),
      ),
      child: const _RegistrationContent(),
    );
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
    _pageController.animateToPage(
      _vm.stepIndex,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
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
    final isComplete = vm.step == RegistrationStep.complete;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isComplete ? null : _buildAppBar(vm),
      body: Column(
        children: [
          if (!isComplete)
            _StepProgressBar(
              currentIndex: vm.stepIndex,
              // complete step is the last — don't count it in progress dots
              total: vm.totalSteps - 1,
            ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StepBasicInfoView(),
                StepProfessionalView(),
                StepInterestsView(),
                StepCompleteView(),
              ],
            ),
          ),
          if (!isComplete) _buildNavBar(context, vm),
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
    final isLastActionStep = vm.step == RegistrationStep.interests;
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
          onPressed: vm.canGoNext ? vm.nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.border,
            foregroundColor: Colors.white,
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
          child: Text(isLastActionStep ? 'Tamamla' : 'Devam Et'),
        ),
      ),
    );
  }

  String _stepTitle(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.basicInfo:
        return 'Temel Bilgiler';
      case RegistrationStep.professional:
        return 'Profesyonel Bilgiler';
      case RegistrationStep.interests:
        return 'İlgi Alanları';
      case RegistrationStep.complete:
        return '';
    }
  }
}

// ──────────────────────────────────────────────
// Adım ilerleme çubuğu
// ──────────────────────────────────────────────
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
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin:
                  EdgeInsets.only(right: i < total - 1 ? AppSpacing.xs : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Kayıt için kullanılan yardımcı navigasyon
// ──────────────────────────────────────────────
class RegistrationNavigation {
  static void goToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }
}
