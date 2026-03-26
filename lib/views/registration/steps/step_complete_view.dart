import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../viewmodels/registration/registration_view_model.dart';

class StepCompleteView extends StatefulWidget {
  const StepCompleteView({super.key});

  @override
  State<StepCompleteView> createState() => _StepCompleteViewState();
}

class _StepCompleteViewState extends State<StepCompleteView>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(
        duration: const Duration(seconds: 4))
      ..play();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.elasticOut,
    );
    _glowAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Staggered entrance
    Future.delayed(const Duration(milliseconds: 200),
        () => mounted ? _scaleCtrl.forward() : null);
    Future.delayed(const Duration(milliseconds: 500),
        () => mounted ? _fadeCtrl.forward() : null);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.read<RegistrationViewModel>().draft;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // ── İçerik ──
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl,
                AppSpacing.xl, AppSpacing.base + bottomPad),
            child: Column(
              children: [
                const Spacer(),

                // ── Animasyonlu check ikonu ──
                ScaleTransition(
                  scale: _scaleAnim,
                  child: AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (_, child) => Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF6C63FF),
                            Color(0xFFF472B6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withValues(alpha: 0.25 + 0.25 * _glowAnim.value),
                            blurRadius: 20 + 20 * _glowAnim.value,
                            spreadRadius: 2 + 4 * _glowAnim.value,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 54),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Başlık ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFF6C63FF),
                            Color(0xFFF472B6),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Hazırsın! 🎉',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Rivorya\'ya hoş geldin.\nSeni bekleyen bağlantılar hazır!',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Özet kartları ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      if (draft.gender != null || draft.city.isNotEmpty)
                        _SummaryCard(
                          icon: Icons.person_outline_rounded,
                          children: [
                            if (draft.gender != null)
                              _summaryGenderLabel(draft.gender!),
                            if (draft.city.isNotEmpty) ...[
                              if (draft.gender != null)
                                const SizedBox(width: AppSpacing.xs),
                              _SummaryChip(
                                label:
                                    '${draft.city}${draft.district.isNotEmpty ? ' · ${draft.district}' : ''}',
                              ),
                            ],
                          ],
                        ),
                      if (draft.jobTitle.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _SummaryCard(
                          icon: Icons.work_outline_rounded,
                          children: [
                            _SummaryChip(label: draft.jobTitle),
                            if (draft.company.isNotEmpty) ...[
                              const SizedBox(width: AppSpacing.xs),
                              _SummaryChip(
                                  label: draft.company,
                                  muted: true),
                            ],
                          ],
                        ),
                      ],
                      if (draft.selectedInterests.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _SummaryCard(
                          icon: Icons.interests_outlined,
                          children: draft.selectedInterests
                              .take(5)
                              .map((i) => _SummaryChip(label: i))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // ── CTA butonu ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _PremiumButton(
                    label: 'Keşfetmeye Başla',
                    onTap: () => context
                        .read<RegistrationViewModel>()
                        .finalizeRegistration(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Sol konfeti ──
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: pi / 4,
            emissionFrequency: 0.06,
            numberOfParticles: 18,
            gravity: 0.18,
            colors: const [
              Color(0xFF8B5CF6),
              Color(0xFF6C63FF),
              Color(0xFFF472B6),
              Color(0xFFFBBF24),
              Color(0xFF34D399),
              Colors.white,
            ],
          ),
        ),

        // ── Sağ konfeti ──
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirection: (3 * pi) / 4,
            emissionFrequency: 0.06,
            numberOfParticles: 18,
            gravity: 0.18,
            colors: const [
              Color(0xFF8B5CF6),
              Color(0xFF6C63FF),
              Color(0xFFF472B6),
              Color(0xFFFBBF24),
              Color(0xFF34D399),
              Colors.white,
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryGenderLabel(dynamic gender) {
    final map = {
      'UserGender.male': ('Erkek', '👨'),
      'UserGender.female': ('Kadın', '👩'),
      'UserGender.other': ('Diğer', '🌈'),
    };
    final entry = map[gender.toString()] ?? ('Belirtilmemiş', '👤');
    return _SummaryChip(label: '${entry.$2} ${entry.$1}');
  }
}

// ──────────────────────────────────────────────
// Premium gradient CTA butonu
// ──────────────────────────────────────────────
class _PremiumButton extends StatefulWidget {
  const _PremiumButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim =
        Tween<double>(begin: 1, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B5CF6), Color(0xFF6C63FF), Color(0xFFF472B6)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Özet kartı (glassmorphism)
// ──────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.children});
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Chip (özet etiket)
// ──────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, this.muted = false});
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? AppColors.surfaceVariant
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: muted
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: muted ? AppColors.textSecondary : AppColors.primary,
        ),
      ),
    );
  }
}

