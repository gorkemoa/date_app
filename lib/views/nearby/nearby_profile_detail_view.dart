import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/nearby/nearby_user_model.dart';

class NearbyProfileDetailView extends StatelessWidget {
  const NearbyProfileDetailView({super.key, required this.user});

  final NearbyUserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildBody(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: user.photoUrl != null
            ? Image.network(
                user.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.person, size: 64,
                      color: AppColors.textDisabled),
                ),
              )
            : Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.person, size: 64,
                    color: AppColors.textDisabled),
              ),
        // Foto üstüne gradient overlay
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- İsim / Yaş / Meslek ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nameAndAge, style: AppTextStyles.headingLarge),
                    if (user.occupation != null) ...[
                      const SizedBox(height: 2),
                      Text(user.occupation!, style: AppTextStyles.bodyLarge),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.success),
                    ),
                    const SizedBox(width: 4),
                    const Text('Müsait',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),

          // --- Mekan & Mesafe ---
          if (user.venueName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.coffee_outlined,
              iconColor: AppColors.accent,
              text: '${user.venueName!}  ·  ${user.distanceLabel}',
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.lg),

          // --- Hakkında ---
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const Text('Hakkında', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(user.bio!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
          ],

          // --- Network Hedefi ---
          if (user.meetGoal != null && user.meetGoal!.isNotEmpty) ...[
            const Text('Network Hedefi', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.handshake_outlined,
              iconColor: AppColors.primary,
              text: user.meetGoal!,
              textStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // --- Kimlerle tanışmak istiyor ---
          if (user.wantToMeetWith.isNotEmpty) ...[
            const Text('Tanışmak İstedikleri', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children:
                  user.wantToMeetWith.map((w) => _ProfileChip(label: w)).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // --- İlgi Alanları ---
          if (user.interests.isNotEmpty) ...[
            const Text('İlgi Alanları', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: user.interests
                  .map((i) => _ProfileChip(label: i, outlined: true))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.base + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Geç'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.swipePass,
                side: const BorderSide(color: AppColors.swipePass),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Text('👋', style: TextStyle(fontSize: 14)),
              label: const Text('Merhaba Gönder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Yardımcı widget'lar
// ──────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.textStyle,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            text,
            style: textStyle ?? AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label, this.outlined = false});

  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
      decoration: BoxDecoration(
        color: outlined
            ? Colors.transparent
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: outlined
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: outlined ? AppColors.textSecondary : AppColors.primary,
        ),
      ),
    );
  }
}
