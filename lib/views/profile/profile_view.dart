import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(ProfileViewModel vm) {
    if (vm.isLoading) return const LoadingView();
    if (vm.hasError) {
      return ErrorStateView(
        message: vm.errorMessage,
        onRetry: () => context.read<ProfileViewModel>().loadProfile(),
      );
    }
    final profile = vm.profile;
    if (profile == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundImage: profile.primaryPhoto != null
                  ? NetworkImage(profile.primaryPhoto!)
                  : null,
              child: profile.primaryPhoto == null
                  ? const Icon(Icons.person, size: 48)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Center(
            child: Text(
              '${profile.name}, ${profile.age}',
              style: AppTextStyles.headingLarge,
            ),
          ),
          if (profile.occupation != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                profile.occupation!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          if (profile.bio != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Hakkında', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(profile.bio!, style: AppTextStyles.bodyLarge),
          ],
          if (profile.interests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('İlgi Alanları', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: profile.interests
                  .map((i) => Chip(label: Text(i)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
