import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/home/home_view_model.dart';
import '../../viewmodels/discover/discover_view_model.dart';
import '../../viewmodels/matches/matches_view_model.dart';
import '../../viewmodels/nearby/nearby_view_model.dart';
import '../../viewmodels/profile/profile_view_model.dart';
import '../../services/demo/demo_discover_service.dart';
import '../../services/demo/demo_match_service.dart';
import '../../services/demo/demo_nearby_service.dart';
import '../../services/demo/demo_profile_service.dart';
import '../discover/discover_view.dart';
import '../matches/matches_view.dart';
import '../nearby/nearby_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(
          create: (_) => NearbyViewModel(nearbyService: DemoNearbyService()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DiscoverViewModel(discoverService: DemoDiscoverService()),
        ),
        ChangeNotifierProvider(
          create: (_) => MatchesViewModel(matchService: DemoMatchService()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfileViewModel(profileService: DemoProfileService()),
        ),
      ],
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  static const List<Widget> _pages = [
    NearbyView(),
    DiscoverView(),
    MatchesView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    return Scaffold(
      body: IndexedStack(
        index: vm.selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _AppBottomNavBar(
        selectedIndex: vm.selectedIndex,
        onTap: vm.onTabChanged,
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.overlayLight,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.location_on_outlined),
          selectedIcon: Icon(Icons.location_on),
          label: 'Yanımdakiler',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Keşfet',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Eşleşmeler',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
