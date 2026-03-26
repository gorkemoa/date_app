import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/matches/matches_view_model.dart';
import '../shared/components/loading_view.dart';
import '../shared/components/empty_state_view.dart';
import '../shared/components/error_state_view.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({super.key});

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchesViewModel>().loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MatchesViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Eşleşmeler')),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(MatchesViewModel vm) {
    if (vm.isLoading) return const LoadingView();
    if (vm.hasError) {
      return ErrorStateView(
        message: vm.errorMessage,
        onRetry: () => context.read<MatchesViewModel>().loadMatches(),
      );
    }
    if (vm.isEmpty) {
      return const EmptyStateView(
        icon: Icons.favorite_outline,
        title: 'Henüz eşleşme yok',
        subtitle: 'Keşfet ekranından birini beğen!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vm.matches.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final match = vm.matches[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 28,
            backgroundImage:
                match.userPhoto != null ? NetworkImage(match.userPhoto!) : null,
            child: match.userPhoto == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(match.userName, style: AppTextStyles.labelLarge),
          subtitle: Text(
            match.lastMessage ?? 'Yeni eşleşme! 🎉',
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: match.hasUnread
              ? CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${match.unreadCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
