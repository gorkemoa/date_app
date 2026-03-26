import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
}
