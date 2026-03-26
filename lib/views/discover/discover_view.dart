import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../viewmodels/discover/discover_view_model.dart';
import '../shared/components/loading_view.dart';
import '../shared/components/empty_state_view.dart';
import '../shared/components/error_state_view.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoverViewModel>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiscoverViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Keşfet')),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(DiscoverViewModel vm) {
    if (vm.isLoading) return const LoadingView();
    if (vm.hasError) {
      return ErrorStateView(
        message: vm.errorMessage,
        onRetry: () => context.read<DiscoverViewModel>().loadCards(),
      );
    }
    if (vm.isEmpty || !vm.hasCards) {
      return EmptyStateView(
        icon: Icons.explore_outlined,
        title: 'Yeni kişi kalmadı',
        subtitle: 'Biraz sonra tekrar kontrol et',
        actionLabel: 'Yenile',
        onAction: () => context.read<DiscoverViewModel>().loadCards(),
      );
    }

    // Kart alanı — sonraki adımda swipe bileşeni buraya gelecek
    return Center(
      child: Text(
        vm.currentCard?.nameAndAge ?? '',
        style: AppTextStyles.headingLarge,
      ),
    );
  }
}
