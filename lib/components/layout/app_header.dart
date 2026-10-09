import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Visual variants of [AppHeader].
enum AppHeaderVariant {
  /// Blue bar with white text, used by Dashboard and Tasks.
  filled,

  /// White bar with dark text, used by Task Details.
  plain,
}

/// App bar shared by every screen.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.variant = AppHeaderVariant.filled,
  });

  final String title;

  /// Menu icon or back arrow.
  final Widget? leading;

  /// Avatar or overflow icon.
  final Widget? trailing;

  final AppHeaderVariant variant;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool filled = variant == AppHeaderVariant.filled;
    final Color foreground = filled
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;

    return AppBar(
      backgroundColor: filled ? AppColors.primary : AppColors.surface,
      foregroundColor: foreground,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyles.appBarTitle.copyWith(color: foreground),
      ),
      leading: leading,
      actions: trailing == null
          ? null
          : <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: trailing,
              ),
            ],
    );
  }
}
