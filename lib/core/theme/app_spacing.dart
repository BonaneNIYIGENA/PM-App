import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spacing scale used for every gap and padding in the app.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii of the app's surfaces.
abstract final class AppRadius {
  static const double card = 14;
  static const double input = 12;
  static const double button = 10;
  static const double chip = 20;
}

/// Fixed heights of the controls that size themselves, so screens can reserve
/// the matching amount of space instead of guessing a number.
abstract final class AppSizes {
  static const double button = 52;
  static const double fab = 56;
  static const double filterButton = 44;
  static const double navBar = 64;

  /// Bottom padding a scroll view needs to stay clear of the floating action
  /// button: [AppSpacing.lg] + [fab] + [AppSpacing.lg].
  static const double fabClearance = 88;
}

/// The soft shadow shared by cards.
abstract final class AppShadows {
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
  ];
}
