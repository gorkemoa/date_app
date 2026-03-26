import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/onboarding/onboarding_slide_model.dart';
import '../../services/demo/demo_onboarding_service.dart';
import '../../viewmodels/onboarding/onboarding_view_model.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          OnboardingViewModel(service: DemoOnboardingService())..load(),
      child: const _OnboardingContent(),
    );
  }
}

class _OnboardingContent extends StatefulWidget {
  const _OnboardingContent();

  @override
  State<_OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<_OnboardingContent> {
  late final PageController _pageController;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext(BuildContext context, OnboardingViewModel vm) {
    if (vm.isLastSlide) {
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
    } else {
      vm.nextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleSkip(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }

  void _onPageChanged(OnboardingViewModel vm, int index) {
    setState(() => _activeIndex = index);
    vm.goToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    if (vm.isLoading || vm.slides.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (vm.hasError) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Bir hata oluştu.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen paged video backgrounds
          PageView.builder(
            controller: _pageController,
            itemCount: vm.slides.length,
            onPageChanged: (i) => _onPageChanged(vm, i),
            itemBuilder: (context, index) {
              return _VideoSlidePage(
                slide: vm.slides[index],
                isActive: index == _activeIndex,
              );
            },
          ),

          // Cinematic gradient overlay
          const _CinematicGradient(),

          // Skip button — top right
          if (!vm.isLastSlide)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              right: AppSpacing.base,
              child: _SkipButton(onTap: () => _handleSkip(context)),
            ),

          // Bottom content: title + desc + dots + button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomContent(
              slide: vm.slides[vm.currentIndex],
              vm: vm,
              onNext: () => _handleNext(context, vm),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Video slide — each page manages its own controller lifecycle
// ─────────────────────────────────────────────────────────────────
class _VideoSlidePage extends StatefulWidget {
  const _VideoSlidePage({required this.slide, required this.isActive});

  final OnboardingSlideModel slide;
  final bool isActive;

  @override
  State<_VideoSlidePage> createState() => _VideoSlidePageState();
}

class _VideoSlidePageState extends State<_VideoSlidePage>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.asset(widget.slide.videoPath);
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setVolume(0);
    if (widget.isActive && mounted) await _controller.play();
    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  void didUpdateWidget(_VideoSlidePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive && _isInitialized) {
      widget.isActive ? _controller.play() : _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized) {
      return const ColoredBox(color: Colors.black);
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Cinematic gradient: darkens top and bottom
// ─────────────────────────────────────────────────────────────────
class _CinematicGradient extends StatelessWidget {
  const _CinematicGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.3, 0.55, 1.0],
          colors: [
            Color(0x55000000),
            Colors.transparent,
            Color(0xBB0A0A1E),
            Color(0xF50A0A1E),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bottom content: title, description, dots, button
// ─────────────────────────────────────────────────────────────────
class _BottomContent extends StatelessWidget {
  const _BottomContent({
    required this.slide,
    required this.vm,
    required this.onNext,
  });

  final OnboardingSlideModel slide;
  final OnboardingViewModel vm;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.xl + bottomPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slide.title,
            style: AppTextStyles.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _PageDots(
                total: vm.totalSlides,
                current: vm.currentIndex,
              ),
              const Spacer(),
              _NextButton(isLast: vm.isLastSlide, onNext: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Page indicator dots
// ─────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  const _PageDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: AppSpacing.xs),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Next / CTA button
// ─────────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  const _NextButton({required this.isLast, required this.onNext});

  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return GestureDetector(
        onTap: onNext,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            'Başlayalım',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onNext,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Skip button
// ─────────────────────────────────────────────────────────────────
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          'Geç',
          style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

