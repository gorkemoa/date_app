import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../core/enums/app_enums.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/demo/demo_auth_service.dart';
import '../../viewmodels/auth/auth_view_model.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(authService: DemoAuthService()),
      child: const _AuthContent(),
    );
  }
}

class _AuthContent extends StatefulWidget {
  const _AuthContent();

  @override
  State<_AuthContent> createState() => _AuthContentState();
}

class _AuthContentState extends State<_AuthContent> {
  late VideoPlayerController _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 3. video olan '9047514-uhd_2160_3840_24fps.mp4' dosyasını direkt veriyoruz
      _initVideo('assets/9047514-uhd_2160_3840_24fps.mp4');
    });
  }

  Future<void> _initVideo(String path) async {
    _videoController = VideoPlayerController.asset(path);
    await _videoController.initialize();
    await _videoController.setLooping(true);
    await _videoController.setVolume(0);
    
    // Kırpılma (glitch) engellemek için aspect ratio ayarını force ediyoruz
    if (mounted) {
      setState(() => _videoReady = true);
      _videoController.play();
    }
  }

  @override
  void dispose() {
    _videoController.pause(); // Dispose öncesi durdurmak stabilite sağlar
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn(BuildContext context, AuthProvider provider) async {
    final vm = context.read<AuthViewModel>();
    final success = await vm.signIn(provider);
    if (success && context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.registration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video background ──
          if (_videoReady)
            IgnorePointer(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge, // Tekrar döngüsünde kırpılmayı (glitch) engeller
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            ),

          // ── Glass Layer (Applied OVER the video) ──
          LiquidGlass.withOwnLayer(
            shape: const LiquidRoundedRectangle(borderRadius: 0),
            settings: LiquidGlassSettings(blur: 7),
            child: const SizedBox.expand(),
          ),

          // ── Cinematic dark gradient overlay ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black54,
                  Colors.black87,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Stack(
              children: [
                // Quick Login Button for testing
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: TextButton.icon(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, AppRoutes.home),
                    icon: const Icon(Icons.bolt, color: Colors.white70, size: 16),
                    label: const Text(
                      'Hızlı Giriş (Test)',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.massive,
                    ),
                    child: _SignInContent(vm: vm, onSignIn: _onSignIn),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Auth page content
// ─────────────────────────────────────────────────────────────────
class _SignInContent extends StatelessWidget {
  const _SignInContent({required this.vm, required this.onSignIn});

  final AuthViewModel vm;
  final Future<void> Function(BuildContext, AuthProvider) onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SmallLogo(),
        const SizedBox(height: AppSpacing.massive),
        Text(
          'Hesabınıza giriş yapın',
          style: AppTextStyles.headingSmall.copyWith(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bir yöntem seçin',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.50),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.massive),
        if (vm.hasError) ...[
          _ErrorBanner(message: vm.errorMessage ?? ''),
          const SizedBox(height: AppSpacing.base),
        ],
        _LinkedInButton(
          isLoading: vm.isLoading,
          onTap: () => onSignIn(context, AuthProvider.linkedin),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _GoogleButton(
                isLoading: vm.isLoading,
                onTap: () => onSignIn(context, AuthProvider.google),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _AppleButton(
                isLoading: vm.isLoading,
                onTap: () => onSignIn(context, AuthProvider.apple),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Auth page components ──

class _SmallLogo extends StatelessWidget {
  const _SmallLogo();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Rivorya',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Social button base
// ─────────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.isLoading,
    this.borderColor,
    this.textColor = Colors.white,
    this.logoBackgroundColor,
  });

  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color? borderColor;
  final Widget icon;
  final String label;
  final bool isLoading;
  final Color textColor;
  final Color? logoBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.2)
              : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: logoBackgroundColor ?? Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: icon,
                  ),
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // To balance the logo width for centering
                ],
              ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SocialButton(
      onTap: onTap,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      borderColor: Colors.white.withValues(alpha: 0.15),
      isLoading: isLoading,
      textColor: Colors.white,
      logoBackgroundColor: Colors.white,
      icon: SvgPicture.asset(
        'assets/google.svg',
        width: 20,
        height: 20,
      ),
      label: 'Google',
    );
  }
}

class _LinkedInButton extends StatelessWidget {
  const _LinkedInButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _SocialButton(
          onTap: onTap,
          backgroundColor: const Color(0xFF0077B5).withValues(alpha: 0.9),
          isLoading: isLoading,
          textColor: Colors.white,
          logoBackgroundColor: Colors.white.withValues(alpha: 0.2),
          icon: SvgPicture.asset(
            'assets/linkedin.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          label: 'LinkedIn ile Devam Et',
        ),
        Positioned(
          top: -10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                SizedBox(width: 4),
                Text(
                  'EN POPÜLER SEÇENEK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SocialButton(
      onTap: onTap,
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      borderColor: Colors.white.withValues(alpha: 0.2),
      isLoading: isLoading,
      textColor: Colors.white,
      logoBackgroundColor: Colors.black.withValues(alpha: 0.5),
      icon: SvgPicture.asset(
        'assets/apple.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
      label: 'Apple',
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

