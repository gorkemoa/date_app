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
              currentIndex: vm.currentIndex,
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
          stops: [0.0, 0.2, 0.6, 1.0],
          colors: [
            Color(0x33000000), // Lightened from 0x55
            Colors.transparent,
            Color(0x77050510), // Lightened from 0xBB
            Color(0xCC050510), // Lightened from 0xF5
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bottom content: staggered entrance animation on every slide change
// ─────────────────────────────────────────────────────────────────
class _BottomContent extends StatefulWidget {
  const _BottomContent({
    required this.slide,
    required this.vm,
    required this.onNext,
    required this.currentIndex,
  });

  final OnboardingSlideModel slide;
  final OnboardingViewModel vm;
  final VoidCallback onNext;
  final int currentIndex;

  @override
  State<_BottomContent> createState() => _BottomContentState();
}

class _BottomContentState extends State<_BottomContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Layer 1 — step badge  (enters first, fastest)
  late final Animation<double> _badgeFade;
  late final Animation<Offset> _badgeSlide;

  // Layer 2 — title
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  // Layer 3 — description
  late final Animation<double> _descFade;
  late final Animation<Offset> _descSlide;

  // Layer 4 — CTA row (dots + button)
  late final Animation<double> _ctaFade;
  late final Animation<Offset> _ctaSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 740),
    );
    _buildAnimations();
    _ctrl.forward();
  }

  void _buildAnimations() {
    // All layers share the same Offset direction (subtle upward drift).
    // Each layer has its own Interval so they enter one after another.
    const slideBegin = Offset(0.0, 0.14);
    const slideEnd = Offset.zero;
    const ease = Curves.easeOutCubic;

    // Layer 1 — badge: 0 → 320ms  (Interval 0.00 – 0.43)
    _badgeFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.43, curve: Curves.easeOut),
    );
    _badgeSlide = Tween(begin: slideBegin, end: slideEnd).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.00, 0.43, curve: ease)),
    );

    // Layer 2 — title: 80ms → 440ms  (Interval 0.11 – 0.59)
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.11, 0.59, curve: Curves.easeOut),
    );
    _titleSlide = Tween(begin: slideBegin, end: slideEnd).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.11, 0.59, curve: ease)),
    );

    // Layer 3 — description: 200ms → 540ms  (Interval 0.27 – 0.73)
    _descFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.27, 0.73, curve: Curves.easeOut),
    );
    _descSlide = Tween(begin: slideBegin, end: slideEnd).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.27, 0.73, curve: ease)),
    );

    // Layer 4 — CTA row: 330ms → 680ms  (Interval 0.45 – 0.92)
    _ctaFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 0.92, curve: Curves.easeOut),
    );
    _ctaSlide = Tween(begin: slideBegin, end: slideEnd).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 0.92, curve: ease)),
    );
  }

  @override
  void didUpdateWidget(_BottomContent old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _stepLabel {
    final n = widget.currentIndex + 1;
    final t = widget.vm.totalSlides;
    return '${n.toString().padLeft(2, '0')}  /  ${t.toString().padLeft(2, '0')}';
  }

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
          // — Layer 1: step badge ——————————————————————————————
          FadeTransition(
            opacity: _badgeFade,
            child: SlideTransition(
              position: _badgeSlide,
              child: _StepBadge(label: _stepLabel),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // — Layer 2: title ———————————————————————————————————
          FadeTransition(
            opacity: _titleFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(
                widget.slide.title,
                style: AppTextStyles.displayMedium.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // — Layer 3: description —————————————————————————————
          FadeTransition(
            opacity: _descFade,
            child: SlideTransition(
              position: _descSlide,
              child: Text(
                widget.slide.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                  height: 1.65,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // — Layer 4: dots + CTA button ———————————————————————
          FadeTransition(
            opacity: _ctaFade,
            child: SlideTransition(
              position: _ctaSlide,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _PageDots(
                    total: widget.vm.totalSlides,
                    current: widget.vm.currentIndex,
                  ),
                  const Spacer(),
                  _NextButton(
                    isLast: widget.vm.isLastSlide,
                    onNext: widget.onNext,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Step counter badge — e.g. "01  /  03"
// ─────────────────────────────────────────────────────────────────
class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.8,
        ),
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
        
        // Match the brand colors per page
        final Color activeColor;
        switch (i) {
          case 0: activeColor = AppColors.primary; break;     // Coral
          case 1: activeColor = AppColors.secondary; break;   // Blue
          case 2: activeColor = AppColors.accent; break;      // Lime
          default: activeColor = Colors.white;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: AppSpacing.xs),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: isActive 
                ? [BoxShadow(color: activeColor.withValues(alpha: 0.4), blurRadius: 8)]
                : null,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, Color(0xFF8CCF1E)], // Lime Gradient
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'Hemen Başlayalım',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textOnAccent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onNext,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Color(0xFF1E1E1E),
          size: 28,
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

