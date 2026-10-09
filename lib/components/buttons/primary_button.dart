import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Full width primary call to action.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Replaces the label with a spinner and blocks further taps.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.button,
      child: ElevatedButton(
        // A loading button is not tappable, so it is passed no callback. The
        // disabled colours are kept identical to the enabled ones below, which
        // keeps the button looking active while it works.
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAction,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primaryAction,
          disabledForegroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: _content(),
      ),
    );
  }

  Widget _content() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textOnPrimary,
        ),
      );
    }

    final Widget labelWidget = Text(label, style: AppTextStyles.button);
    if (icon == null) {
      return labelWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.textOnPrimary),
        const SizedBox(width: AppSpacing.sm),
        labelWidget,
      ],
    );
  }
}
