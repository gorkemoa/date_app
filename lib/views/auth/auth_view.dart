import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/app_enums.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
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

class _AuthContent extends StatelessWidget {
  const _AuthContent();

  Future<void> _onSignIn(
      BuildContext context, AuthProvider provider) async {
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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _HeroSection(),
          Expanded(child: _ActionsSection(vm: vm, onSignIn: _onSignIn)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Üst hero gradient bölümü
// ──────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        topPad + AppSpacing.massive,
        AppSpacing.xxl,
        AppSpacing.massive,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A52E8), Color(0xFF8B7FFF), Color(0xFFF0EEFF)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.lg,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          const Text(
            'Rivorya',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Doğru kişilerle tanışmanın\nen akıllı yolu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Alt aksiyon bölümü
// ──────────────────────────────────────────────
class _ActionsSection extends StatelessWidget {
  const _ActionsSection({required this.vm, required this.onSignIn});

  final AuthViewModel vm;
  final Future<void> Function(BuildContext, AuthProvider) onSignIn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hesabınıza giriş yapın',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Devam etmek için bir yöntem seçin',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
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
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Sosyal giriş butonu bazı
// ──────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
    required this.isLoading,
    this.borderColor,
    this.loaderColor = AppColors.primary,
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
          boxShadow: AppShadows.sm,
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
      backgroundColor: AppColors.surface,
      borderColor: AppColors.border,
      isLoading: isLoading,
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
                color: AppColors.textPrimary),
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

class _AppleLogoIcon extends StatelessWidget {
  const _AppleLogoIcon();

  @override
  Widget build(BuildContext context) {
    // Apple logosu — beyaz dolgu içinde stilize 'A' harfi
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

class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SocialButton(
      onTap: onTap,
      backgroundColor: const Color(0xFF1C1C1E),
      isLoading: isLoading,
      loaderColor: Colors.white,
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
                color: Colors.white),
          ),
        ],
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
        color: AppColors.swipePass.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.swipePass.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              size: 16, color: AppColors.swipePass),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.swipePass),
            ),
          ),
        ],
      ),
    );
  }
}
