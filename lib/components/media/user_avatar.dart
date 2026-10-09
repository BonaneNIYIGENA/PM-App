import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Circular avatar that shows an image when one is available and falls back to
/// the user's initials otherwise.
class UserAvatar extends StatelessWidget {
  /// Standard avatar: tinted circle with the user's initials.
  const UserAvatar({
    super.key,
    this.imageAsset,
    this.initials,
    this.size = 32,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Avatar for the blue app header: white circle, primary coloured initials.
  const UserAvatar.onPrimary({super.key, this.initials, this.size = 32})
    : imageAsset = null,
      backgroundColor = AppColors.surface,
      foregroundColor = AppColors.primary;

  /// Avatar image; takes precedence over [initials].
  final String? imageAsset;

  /// Up to two letters drawn when [imageAsset] is null.
  final String? initials;

  final double size;

  /// Defaults to [AppColors.statTotalBg].
  final Color? backgroundColor;

  /// Defaults to [AppColors.textPrimary].
  final Color? foregroundColor;

  /// Derives up to two uppercase initials from [name]: `Sarah Lee` -> `SL`.
  static String initialsFrom(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '';
    }
    return parts.take(2).map((String part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final String? label = initials == null || initials!.isEmpty
        ? null
        : initials!.toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.statTotalBg,
        shape: BoxShape.circle,
      ),
      child: imageAsset == null
          ? _initials(label)
          : Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) => _initials(label),
            ),
    );
  }

  Widget _initials(String? label) {
    if (label == null) {
      return Icon(
        Icons.person,
        size: size / 2,
        color: foregroundColor ?? AppColors.textPrimary,
      );
    }
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        fontSize: size * 0.38,
        fontWeight: FontWeight.w700,
        color: foregroundColor ?? AppColors.textPrimary,
      ),
    );
  }
}
