import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// One `label: value` line of the task details screen.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;

  /// Widget shown after the label, for example a text, an avatar or a field.
  final Widget value;

  /// Fixed label column so the values of consecutive rows line up.
  static const double labelWidth = 110;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: labelWidth,
          child: Text(label, style: AppTextStyles.subtitle),
        ),
        Expanded(child: value),
      ],
    );
  }
}
