import 'package:flutter/material.dart';
import '../../views/auth/auth_view.dart';
import '../../views/home/home_view.dart';
import '../../views/onboarding/onboarding_view.dart';
import '../../views/registration/registration_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String registration = '/registration';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String discoverDetail = '/discover/detail';
  static const String matches = '/matches';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String nearbyProfile = '/nearby/profile';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const AuthView(),
        auth: (_) => const AuthView(),
        registration: (_) => const RegistrationView(),
        onboarding: (_) => const OnboardingView(),
        home: (_) => const HomeView(),
      };
}
