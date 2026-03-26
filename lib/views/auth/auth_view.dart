import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
      _initVideo(context.read<AuthViewModel>().backgroundVideoPath);
    });
  }

  Future<void> _initVideo(String path) async {
    _videoController = VideoPlayerController.asset(path);
    await _videoController.initialize();
    await _videoController.setLooping(true);
    await _videoController.setVolume(0);
    await _videoController.play();
    if (mounted) setState(() => _videoReady = true);
  }

  @override
  void dispose() {
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
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // ── Cinematic dark gradient overlay ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.25, 0.55, 1.0],
                colors: [
                  Color(0x77000000),
                  Colors.transparent,
                  Color(0xCC050510),
                  Color(0xFA050510),
                ],
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                _BrandLogo(),
                const SizedBox(height: AppSpacing.lg),
                const _TagLine(),
                const Spacer(),
                _BottomCard(vm: vm, onSignIn: _onSignIn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Brand mark
// ─────────────────────────────────────────────────────────────────
class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        const Text(
          'Rivorya',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Tag line
// ─────────────────────────────────────────────────────────────────
class _TagLine extends StatelessWidget {
  const _TagLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.massive),
      child: Text(
        'Doğru insanlarla yüz yüze,\ndoğru an, doğru yerde tanış.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Colors.white.withValues(alpha: 0.70),
          height: 1.6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bottom glass card with buttons
// ─────────────────────────────────────────────────────────────────
class _BottomCard extends StatelessWidget {
  const _BottomCard({required this.vm, required this.onSignIn});

  final AuthViewModel vm;
  final Future<void> Function(BuildContext, AuthProvider) onSignIn;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + bottomPad,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hesabınıza giriş yapın',
            style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Devam etmek için bir yöntem seçin',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (vm.hasError) ...[
            _ErrorBanner(message: vm.errorMessage ?? ''),
            const SizedBox(height: AppSpacing.base),
          ],
          _GoogleButton(
            isLoading: vm.isLoading,
            onTap: () => onSignIn(context, AuthProvider.google),
          ),
          const SizedBox(height: AppSpacing.md),
          _AppleButton(
            isLoading: vm.isLoading,
            onTap: () => onSignIn(context, AuthProvider.apple),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Devam ederek Kullanım Koşullarını ve Gizlilik Politikasını kabul etmiş olursunuz.',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
    required this.child,
    required this.isLoading,
    this.borderColor,
    this.loaderColor = Colors.white,
  });

  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color? borderColor;
  final Widget child;
  final bool isLoading;
  final Color loaderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
                  ),
                ),
              )
            : child,
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
      backgroundColor: Colors.white,
      isLoading: isLoading,
      loaderColor: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleLogo(),
          const SizedBox(width: AppSpacing.sm),
          const Text(
            'Google ile Devam Et',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4),
          ),
        ),
      ),
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
      backgroundColor: const Color(0xFF1C1C1E),
      borderColor: Colors.white.withValues(alpha: 0.15),
      isLoading: isLoading,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AppleLogoIcon(),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Apple ile Devam Et',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppleLogoIcon extends StatelessWidget {
  const _AppleLogoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '\uF8FF',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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

