import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF17233B);
  static const navy = Color(0xFF263B68);
  static const canvas = Color(0xFFF5F7FB);
  static const teal = Color(0xFF178A80);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: navy,
      primary: navy,
      secondary: teal,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE9EDF4)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFDCE2EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFDCE2EC)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1626),
    colorScheme: ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.dark,
      primary: const Color(0xFF8FA8E8),
      secondary: teal,
      surface: const Color(0xFF182036),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F1626),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF182036),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF2A3550)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF182036),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF2A3550)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF2A3550)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}

// Accent colors used by badges and icons, one set per brightness.
class AppColors {
  const AppColors({
    required this.violet,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.pink,
  });

  final Color violet;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color pink;

  List<Color> get palette => [violet, info, success, warning, pink, danger];

  static const light = AppColors(
    violet: Color(0xFF6C4CF1),
    success: Color(0xFF0F9F78),
    warning: Color(0xFFD97706),
    danger: Color(0xFFE0383E),
    info: Color(0xFF1E3A8A),
    pink: Color(0xFFD6409F),
  );

  static const dark = AppColors(
    violet: Color(0xFFA08DFF),
    success: Color(0xFF3DD6A3),
    warning: Color(0xFFFFB020),
    danger: Color(0xFFFF6B70),
    info: Color(0xFF7C9BF0),
    pink: Color(0xFFFF7EC6),
  );
}

// Short names so screens can write context.scheme instead of Theme.of(context).
extension AppThemeContext on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  AppColors get colors => isDark ? AppColors.dark : AppColors.light;

  // A light tint of an accent color that works on the card surface.
  Color soft(Color accent, {double? alpha}) => Color.alphaBlend(
    accent.withValues(alpha: alpha ?? (isDark ? .18 : .12)),
    scheme.surface,
  );
}
