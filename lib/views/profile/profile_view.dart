import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/profile/profile_model.dart';
import '../../viewmodels/profile/profile_view_model.dart';
import '../shared/components/loading_view.dart';
import '../shared/components/error_state_view.dart';
import '../../viewmodels/registration/registration_view_model.dart';

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
      final regVm = context.read<RegistrationViewModel>();
      context.read<ProfileViewModel>().loadProfile(regDraft: regVm.draft);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: LoadingView(),
      );
    }

    if (vm.hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: ErrorStateView(
          message: vm.errorMessage,
          onRetry: () => context.read<ProfileViewModel>().loadProfile(),
        ),
      );
    }

    final profile = vm.profile;
    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _ExecutiveProfileHeader(profile: profile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExecutiveInfo(profile: profile),
                  const SizedBox(height: 32),
                  _ExecutiveActions(),
                  if (profile.profileCompletionPercent != null && profile.profileCompletionPercent! < 100) ...[
                    const SizedBox(height: 32),
                    _NetworkStrengthCard(percent: profile.profileCompletionPercent!),
                  ],
                  if (profile.bio != null) ...[
                    const SizedBox(height: 48),
                    _ProfileSection(title: 'Hakkımda', content: profile.bio!),
                  ],
                  if (profile.interests.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _SkillCloud(interests: profile.interests),
                  ],
                  const SizedBox(height: 48),
                  _SettingsMenu(),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Executive Header
// ──────────────────────────────────────────────
class _ExecutiveProfileHeader extends StatelessWidget {
  const _ExecutiveProfileHeader({required this.profile});
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (profile.primaryPhoto != null)
              Image.network(profile.primaryPhoto!, fit: BoxFit.cover)
            else
              Container(color: AppColors.secondary),
            
            // Sophisticated Shading
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 0.85, 1.0],
                  colors: [
                    Colors.black26,
                    Colors.transparent,
                    Colors.black54,
                    Colors.white,
                  ],
                ),
              ),
            ),

            // Top Buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: Row(
                children: [
                  _GlassIconButton(icon: Icons.qr_code_rounded, onTap: () {}),
                  const SizedBox(width: 12),
                  _GlassIconButton(icon: Icons.logout_rounded, onTap: () {}, color: Colors.white.withValues(alpha: 0.8)),
                ],
              ),
            ),

            // Identity Overlay
            Positioned(
              left: 24,
              bottom: 32,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Info & Headline
// ──────────────────────────────────────────────
class _ExecutiveInfo extends StatelessWidget {
  const _ExecutiveInfo({required this.profile});
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.occupation ?? 'Profesyonel Üye',
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _LabelMetric(label: 'Konum', value: profile.location ?? 'Global'),
            const SizedBox(width: 32),
            _LabelMetric(label: 'Rol', value: profile.isVerified ? 'Onaylı Partner' : 'Profesyonel'),
          ],
        ),
      ],
    );
  }
}

class _LabelMetric extends StatelessWidget {
  const _LabelMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Professional Actions
// ──────────────────────────────────────────────
class _ExecutiveActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SolidButton(
            label: 'PROFİLİ DÜZENLE',
            onTap: () {},
            icon: Icons.edit_note_rounded,
          ),
        ),
        const SizedBox(width: 12),
        _SecondaryActionButton(icon: Icons.ios_share_rounded, onTap: () {}),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Network Strength / Completion
// ──────────────────────────────────────────────
class _NetworkStrengthCard extends StatelessWidget {
  const _NetworkStrengthCard({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROFİL GÜCÜ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                '%$percent',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Profesyonel ağınızı genişletmek için eksik bilgileri tamamlayın.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Modular Components
// ──────────────────────────────────────────────
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        const SizedBox(height: 16),
        Text(
          content,
          style: AppTextStyles.bodyLarge.copyWith(height: 1.7, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SkillCloud extends StatelessWidget {
  const _SkillCloud({required this.interests});
  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Uzmanlıklar & Yetkinlikler'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: interests.map((i) => _SkillBadge(label: i)).toList(),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Container(width: 24, height: 4, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}

class _SkillBadge extends StatelessWidget {
  const _SkillBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Settings Menu
// ──────────────────────────────────────────────
class _SettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuTile(icon: Icons.notifications_none_rounded, label: 'Bildirimler'),
        _MenuTile(icon: Icons.shield_outlined, label: 'Gizlilik ve Güvenlik'),
        _MenuTile(icon: Icons.help_outline_rounded, label: 'Yardım Merkezi'),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Base UI Elements
// ──────────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color ?? Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _SolidButton extends StatelessWidget {
  const _SolidButton({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
