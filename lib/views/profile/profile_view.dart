import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/profile/profile_model.dart';
import '../../viewmodels/profile/profile_view_model.dart';
import '../shared/components/loading_view.dart';
import '../shared/components/error_state_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingView(),
      );
    }

    if (vm.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorStateView(
          message: vm.errorMessage,
          onRetry: () => context.read<ProfileViewModel>().loadProfile(),
        ),
      );
    }

    final profile = vm.profile;
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ProfileHeroHeader(profile: profile)),
          SliverToBoxAdapter(child: _ProfileActionBar()),
          if (profile.profileCompletionPercent != null &&
              profile.profileCompletionPercent! < 100)
            SliverToBoxAdapter(
              child: _CompletionCard(
                percent: profile.profileCompletionPercent!,
              ),
            ),
          if (profile.bio != null)
            SliverToBoxAdapter(child: _BioCard(bio: profile.bio!)),
          if (profile.interests.isNotEmpty)
            SliverToBoxAdapter(
              child: _InterestsCard(interests: profile.interests),
            ),
          SliverToBoxAdapter(child: _SettingsCard()),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Hero header
// ──────────────────────────────────────────────
class _ProfileHeroHeader extends StatelessWidget {
  const _ProfileHeroHeader({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fotoğraf
          profile.primaryPhoto != null
              ? Image.network(
                  profile.primaryPhoto!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _HeroPlaceholder(name: profile.name),
                )
              : _HeroPlaceholder(name: profile.name),
          // Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.50, 1.0],
                colors: [
                  Colors.transparent,
                  Color(0x44000000),
                  Color(0xE0000000),
                ],
              ),
            ),
          ),
          // Üst bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassIconButton(icon: Icons.arrow_back_ios_new_rounded),
                    _GlassIconButton(icon: Icons.settings_outlined),
                  ],
                ),
              ),
            ),
          ),
          // Alt bilgi
          Positioned(
            bottom: AppSpacing.base,
            left: AppSpacing.base,
            right: AppSpacing.base,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.info,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                if (profile.occupation != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    profile.occupation!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (profile.location != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.60),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        profile.location!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.60),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.40),
            fontSize: 88,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Hızlı eylem çubuğu
// ──────────────────────────────────────────────
class _ProfileActionBar extends StatelessWidget {
  const _ProfileActionBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                ),
                borderRadius: BorderRadius.circular(AppRadius.base),
                boxShadow: AppShadows.secondaryGlow,
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: AppColors.textOnSecondary),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Profili Düzenle',
                      style: TextStyle(
                        color: AppColors.textOnSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.base),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.sm,
            ),
            child: const Icon(
              Icons.share_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Profil tamamlanma kartı
// ──────────────────────────────────────────────
class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.xs, AppSpacing.base, AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.30)),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rocket_launch_outlined,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Profil Gücü',
                  style: AppTextStyles.labelLarge,
                ),
                const Spacer(),
                Text(
                  '%$percent',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Profilini tamamlayarak daha fazla bağlantı kur',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Bio kartı
// ──────────────────────────────────────────────
class _BioCard extends StatelessWidget {
  const _BioCard({required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.xs, AppSpacing.base, AppSpacing.xs),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hakkında', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(bio, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// İlgi alanları kartı
// ──────────────────────────────────────────────
class _InterestsCard extends StatelessWidget {
  const _InterestsCard({required this.interests});

  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.xs, AppSpacing.base, AppSpacing.xs),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İlgi Alanları', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: interests.map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    interest,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Ayarlar kartı
// ──────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.xs, AppSpacing.base, AppSpacing.xs),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Bildirimler',
            ),
            const Divider(
                height: 1, color: AppColors.border, indent: 56),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'Gizlilik',
            ),
            const Divider(
                height: 1, color: AppColors.border, indent: 56),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              label: 'Yardım',
            ),
            const Divider(
                height: 1, color: AppColors.border, indent: 56),
            _SettingsTile(
              icon: Icons.logout_rounded,
              label: 'Çıkış Yap',
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 16, color: effectiveColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
