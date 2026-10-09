import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Circular floating action button used to create a task.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final IconData icon;

  /// Tag used by the FAB hero animation.
  ///
  /// Defaults to `null`, which disables the hero flight. The app shell keeps
  /// every tab alive inside an [IndexedStack] and more than one of them shows a
  /// FAB, so Flutter's default tag would appear twice in the same route and
  /// trip the "multiple heroes share the same tag" assertion.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.fab,
      height: AppSizes.fab,
      child: FloatingActionButton(
        heroTag: heroTag,
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
