import 'package:flutter/material.dart';

/// Every colour used by the app.
///
/// Screens and components never hard-code a colour: they reference a token
/// from here, either directly or through a component default.
abstract final class AppColors {
  /// Header background and active icons.
  static const Color primary = Color(0xFF2F5DA8);

  /// Primary call to action: Sign In, Edit Task, FAB, links, selections.
  static const Color primaryAction = Color(0xFF1769D6);

  /// Scaffold background.
  static const Color background = Color(0xFFF5F8FC);

  /// Cards and inputs.
  static const Color surface = Color(0xFFFFFFFF);

  /// Card and input outlines.
  static const Color border = Color(0xFFE3E8EF);

  /// Titles and task names.
  static const Color textPrimary = Color(0xFF1B2430);

  /// Subtitles, hints and categories.
  static const Color textSecondary = Color(0xFF6B7685);

  /// Text drawn on top of [primary] or [primaryAction].
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Total Tasks stat card.
  static const Color statTotalBg = Color(0xFFE8F0FE);
  static const Color statTotalFg = Color(0xFF2F5DA8);

  /// On Track stat card and SLA card.
  static const Color onTrackBg = Color(0xFFE3F5EA);
  static const Color onTrack = Color(0xFF1F9D55);
  static const Color onTrackChipBg = Color(0xFFD3F0DF);

  /// At Risk stat card.
  static const Color atRiskBg = Color(0xFFFFF3DC);
  static const Color atRisk = Color(0xFFE8A317);
  static const Color atRiskChipBg = Color(0xFFFFF0C7);
  static const Color atRiskText = Color(0xFFB7791F);

  /// Overdue stat card.
  static const Color overdueBg = Color(0xFFFDE8EA);
  static const Color overdue = Color(0xFFD64545);
  static const Color overdueChipBg = Color(0xFFFDE0E0);

  /// To Do chip.
  static const Color todoChipBg = Color(0xFFEEF0F3);
  static const Color todoText = Color(0xFF5F6B7A);

  /// Donut chart segments.
  static const Color chartOnTrack = Color(0xFF3DBE7A);
  static const Color chartAtRisk = Color(0xFFF5C242);
  static const Color chartOverdue = Color(0xFFE0524D);
  static const Color chartCompleted = Color(0xFF8F9BB3);

  /// "High" priority text.
  static const Color priorityHigh = Color(0xFFE03131);

  /// Unselected bottom navigation items.
  static const Color navInactive = Color(0xFF8A94A6);

  /// Background of an unselected filter chip.
  static const Color filterChipBg = Color(0xFFEEF3FA);

  /// Black at 5% opacity, used by the soft card shadow.
  static const Color shadow = Color(0x0D000000);
}
