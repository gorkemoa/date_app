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
}
