class AppConstants {
  AppConstants._();

  static const String appName = 'DateApp';
  static const String appVersion = '1.0.0';

  // Demo simülasyon gecikmeleri
  static const Duration shortDelay = Duration(milliseconds: 600);
  static const Duration mediumDelay = Duration(milliseconds: 1000);
  static const Duration longDelay = Duration(milliseconds: 1500);

  // Swipe
  static const double swipeThreshold = 100.0;
  static const int maxSwipeCards = 10;

  // Pagination
  static const int defaultPageSize = 20;

  // Background video assets
  static const List<String> onboardingVideoPaths = [
    'assets/4318550-hd_1080_1920_30fps.mp4',
    'assets/6912098-hd_1080_1920_25fps.mp4',
    'assets/9047514-uhd_2160_3840_24fps.mp4',
  ];
}
