import 'package:flutter/material.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/home/home_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String discoverDetail = '/discover/detail';
  static const String matches = '/matches';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const OnboardingView(),
        onboarding: (_) => const OnboardingView(),
        home: (_) => const HomeView(),
      };
}
