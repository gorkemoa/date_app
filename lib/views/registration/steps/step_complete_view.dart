import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StepRulesView extends StatelessWidget {
  const StepRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          const Text('Topluluk Kuralları', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Rivorya'da güvenli ve saygılı bir ortam için herkes bu kurallara "
            'uymakla yükümlüdür.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _WarningCard(
            icon: Icons.warning_amber_rounded,
            color: AppColors.error,
            title: 'Kötü davranış = Kalıcı ban',
            body: 'Taciz, spam veya kural ihlali tespit edildiğinde hesabın '
                'kalıcı olarak kapatılır.',
          ),
          const SizedBox(height: AppSpacing.md),
          _WarningCard(
            icon: Icons.people_alt_outlined,
            color: AppColors.warning,
            title: 'Seni davet eden kişi de etkilenir',
            body: 'Kural ihlali yapman, seni davet eden kişinin hesabını da '
                'olumsuz etkiler. Referansını koru.',
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Temel Kurallar', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.md),
          const _RuleItem(
            icon: Icons.favorite_border_rounded,
            text: 'Diğer üyelere saygılı ve nazik davran.',
          ),
          const _RuleItem(
            icon: Icons.verified_user_outlined,
            text: 'Gerçek kimliğinle katıl, sahte profil oluşturma.',
          ),
          const _RuleItem(
            icon: Icons.block_rounded,
            text: 'Taciz, hakaret veya ayrımcılık kesinlikle yasaktır.',
          ),
          const _RuleItem(
            icon: Icons.no_photography_outlined,
            text: 'İzinsiz fotoğraf veya kişisel bilgi paylaşma.',
          ),
          const _RuleItem(
            icon: Icons.campaign_outlined,
            text: 'Spam veya reklam amaçlı içerik paylaşma.',
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: AppTextStyles.bodySmall.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text, style: AppTextStyles.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
