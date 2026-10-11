import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF1B1B1F);
  static const navy = Color(0xFF26262C);
  static const canvas = Colors.white;
  static const teal = Color(0xFFF97316);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: navy,
      primary: navy,
      secondary: teal,
      surface: Colors.white,
    ).copyWith(outlineVariant: const Color(0xFFEDEDF0)),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
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
        side: const BorderSide(color: Color(0xFFE8E8EA)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFD9D9DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFD9D9DD)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.dark,
      primary: const Color(0xFFFF9A4D),
      secondary: teal,
      surface: const Color(0xFF121214),
    ).copyWith(outlineVariant: const Color(0xFF26262A)),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF121214),
      surfaceTintColor: Colors.transparent,
      constraints: BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000000),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF121214),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF2A2A2E)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF121214),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF2A2A2E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF2A2A2E)),
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
    violet: Color(0xFFF97316),
    success: Color(0xFF0F9F78),
    warning: Color(0xFFCA8A04),
    danger: Color(0xFFE0383E),
    info: Color(0xFF3F3F46),
    pink: Color(0xFFD6409F),
  );

  static const dark = AppColors(
    violet: Color(0xFFFFA24D),
    success: Color(0xFF3DD6A3),
    warning: Color(0xFFFACC15),
    danger: Color(0xFFFF6B70),
    info: Color(0xFFC9C9D1),
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
