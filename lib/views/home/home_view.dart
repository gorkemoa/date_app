import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../viewmodels/home/home_view_model.dart';
import '../../viewmodels/discover/discover_view_model.dart';
import '../../viewmodels/matches/matches_view_model.dart';
import '../../viewmodels/nearby/nearby_view_model.dart';
import '../../viewmodels/profile/profile_view_model.dart';
import '../../viewmodels/notifications/notifications_view_model.dart';
import '../../services/demo/demo_discover_service.dart';
import '../../services/demo/demo_match_service.dart';
import '../../services/demo/demo_nearby_service.dart';
import '../../services/demo/demo_notification_service.dart';
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
          create: (_) => ProfileViewModel(profileService: DemoProfileService()),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsViewModel(
              notificationService: DemoNotificationService()),
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
      body: IndexedStack(index: vm.selectedIndex, children: _pages),
      bottomNavigationBar: _AppBottomNavBar(
        selectedIndex: vm.selectedIndex,
        onTap: vm.onTabChanged,
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _labels = ['Yakında', 'Keşfet', 'Bağlantılar', 'Profil'];
  static const _icons = [
    Icons.location_on_outlined,
    Icons.explore_outlined,
    Icons.people_outline_rounded,
    Icons.person_outline_rounded,
  ];
  static const _activeIcons = [
    Icons.location_on_rounded,
    Icons.explore_rounded,
    Icons.people_rounded,
    Icons.person_rounded,
  ];

  // Per-tab active colors: Yakında=coral, Keşfet=mavi, Bağlantılar=lime, Profil=coral
  static const _tabColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.primary,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: List.generate(4, (i) {
              final isActive = i == selectedIndex;
              final tabColor = _tabColors[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: isActive
                            ? BoxDecoration(
                                color: tabColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              )
                            : null,
                        child: Icon(
                          isActive ? _activeIcons[i] : _icons[i],
                          size: 22,
                          color: isActive ? tabColor : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive ? tabColor : AppColors.textDisabled,
                        ),
                        child: Text(_labels[i]),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
