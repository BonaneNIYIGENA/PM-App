import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Circular floating action button used to create a task.
class AppFab extends StatelessWidget {
  const AppFab({super.key, this.onPressed, this.icon = Icons.add});

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.fab,
      height: AppSizes.fab,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.primaryAction,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 3,
        highlightElevation: 5,
        shape: const CircleBorder(),
        child: Icon(icon, size: 26),
      ),
    );
  }
}
