import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../auth/auth_view.dart';
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
  late final LiquidController _liquidController;
  int _activeIndex = 0;
  List<VideoPlayerController>? _controllers;
  bool _controllersInitializing = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _liquidController = LiquidController();
  }

  @override
  void dispose() {
    _controllers?.forEach((c) => c.dispose());
    super.dispose();
  }

  // Manual loop listener — seeks back before the video actually ends,
  // avoiding the native loop's brief black/frozen frame.
  void _onVideoPosition(VideoPlayerController c) {
    if (!c.value.isInitialized || !c.value.isPlaying) return;
    final duration = c.value.duration;
    if (duration == Duration.zero) return;
    if (c.value.position >= duration - const Duration(milliseconds: 180)) {
      c.seekTo(Duration.zero);
    }
  }

  Future<void> _initControllersIfNeeded(List<OnboardingSlideModel> slides) async {
    if (_controllers != null || _controllersInitializing) return;
    _controllersInitializing = true;

    final controllers = slides
        .map((s) => VideoPlayerController.asset(s.videoPath))
        .toList();

    await Future.wait(
      controllers.map((c) async {
        try {
          await c.initialize();
          // Manual loop to prevent native seek black frame
          await c.setLooping(false);
          await c.setVolume(0);
          c.addListener(() => _onVideoPosition(c));
          // Pre-buffer first frame
          await c.play();
          await c.pause();
          await c.seekTo(Duration.zero);
        } catch (e) {
          debugPrint('Video init error: $e');
        }
      }),
    );

    if (!mounted) {
      for (final c in controllers) c.dispose();
      return;
    }

    setState(() => _controllers = controllers);
    controllers[0].play();
  }

  void _handleNext(BuildContext context, OnboardingViewModel vm) {
    if (_isAnimating) return;
    if (vm.isLastSlide) {
      _navigateToAuth(context);
    } else {
      setState(() => _isAnimating = true);
      _liquidController.animateToPage(
        page: _activeIndex + 1,
        duration: 800,
      );
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _isAnimating = false);
      });
    }
  }

  void _handleSkip(BuildContext context) {
    if (_isAnimating) return;
    _navigateToAuth(context);
  }

  void _navigateToAuth(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Wave originates from the bottom-right (where the CTA button lives)
    final origin = Offset(size.width, size.height);
    Navigator.of(context).pushReplacement(
      _LiquidWaveRoute(
        page: const AuthView(),
        center: origin,
      ),
    );
  }

  void _onPageChanged(OnboardingViewModel vm, int index) {
    if (_activeIndex == index) return;
    final previous = _activeIndex;
    setState(() => _activeIndex = index);
    vm.goToPage(index);

    if (_controllers != null) {
      _controllers![previous].pause();
      _controllers![previous].seekTo(Duration.zero);
      _controllers![index].play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    if (vm.isLoading || vm.slides.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (vm.hasError) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Bir hata oluştu.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    // Kick off pre-initialization (idempotent)
    _initControllersIfNeeded(vm.slides);

    // Show loading until all controllers are ready
    if (_controllers == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen Liquid Swipe — controllers are pre-initialized, no flicker
          LiquidSwipe.builder(
            itemCount: vm.slides.length,
            itemBuilder: (context, index) {
              return _VideoSlidePage(
                key: ValueKey(index),
                controller: _controllers![index],
              );
            },
            liquidController: _liquidController,
            onPageChangeCallback: (i) => _onPageChanged(vm, i),
            enableLoop: false,
            fullTransitionValue: 600,
            enableSideReveal: false,
            waveType: WaveType.liquidReveal,
            ignoreUserGestureWhileAnimating: true,
          ),

          // Cinematic gradient overlay
          const _CinematicGradient(),

          // Progress indicators (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Row(
              children: List.generate(
                vm.slides.length,
                (index) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    decoration: BoxDecoration(
                      color: index <= _activeIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Skip button
          if (!vm.isLastSlide)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.lg,
              right: AppSpacing.lg,
              child: _SkipButton(
                onTap: () => _handleSkip(context),
                enabled: !_isAnimating,
              ),
            ),

          // Bottom content: title + desc + button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomContent(
              slide: vm.slides[_activeIndex],
              vm: vm,
              onNext: () => _handleNext(context, vm),
              currentIndex: _activeIndex,
              enabled: !_isAnimating,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Video slide — receives a pre-initialized controller, no loading state
// ─────────────────────────────────────────────────────────────────
class _VideoSlidePage extends StatelessWidget {
  const _VideoSlidePage({
    super.key,
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        if (!value.isInitialized) {
          return const SizedBox.expand(
            child: DecoratedBox(decoration: BoxDecoration(color: Colors.black)),
          );
        }

        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: value.size.width,
              height: value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        );
      },
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
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 0.7, 1.0],
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.9),
            ],
          ),
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
    required this.enabled,
  });

  final OnboardingSlideModel slide;
  final OnboardingViewModel vm;
  final VoidCallback onNext;
  final int currentIndex;
  final bool enabled;

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
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl + bottomPad,
      ),
      child: LiquidGlass.withOwnLayer(
        shape: const LiquidRoundedRectangle(borderRadius: 32),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // — Layer 3: description —————————————————————————————
              FadeTransition(
                opacity: _descFade,
                child: SlideTransition(
                  position: _descSlide,
                  child: Text(
                    widget.slide.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
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
                        enabled: widget.enabled,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
  const _NextButton({
    required this.isLast,
    required this.onNext,
    required this.enabled,
  });

  final bool isLast;
  final VoidCallback onNext;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return GestureDetector(
        onTap: enabled ? onNext : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFF8CCF1E)],
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
        ),
      );
    }

    return GestureDetector(
      onTap: enabled ? onNext : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Skip button
// ─────────────────────────────────────────────────────────────────
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap, required this.enabled});

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
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

// ─────────────────────────────────────────────────────────────────
// Liquid wave page route — circular reveal from given origin point
// ─────────────────────────────────────────────────────────────────
class _LiquidWaveRoute extends PageRouteBuilder {
  _LiquidWaveRoute({required Widget page, required this.center})
      : super(
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return _LiquidRevealTransition(
              animation: animation,
              center: center,
              child: child,
            );
          },
        );

  final Offset center;
}

class _LiquidRevealTransition extends StatelessWidget {
  const _LiquidRevealTransition({
    required this.animation,
    required this.center,
    required this.child,
  });

  final Animation<double> animation;
  final Offset center;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final radius = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ).value *
            maxRadius;

        return ClipPath(
          clipper: _CircleRevealClipper(center: center, radius: radius),
          child: child,
        );
      },
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  const _CircleRevealClipper({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleRevealClipper old) => old.radius != radius;
}
