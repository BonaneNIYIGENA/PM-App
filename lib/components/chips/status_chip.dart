import 'package:flutter/material.dart';

import '../../core/models/task_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Colours a status is rendered with.
typedef StatusColors = ({Color background, Color foreground});

/// Pill that labels the status of a task.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final TaskStatus status;

  /// Background and foreground pair for [status].
  ///
  /// Other components that are tinted by a status (for example the SLA card)
  /// reuse this instead of declaring their own mapping.
  static StatusColors colorsFor(TaskStatus status) => switch (status) {
    TaskStatus.onTrack => (
      background: AppColors.onTrackChipBg,
      foreground: AppColors.onTrack,
    ),
    TaskStatus.atRisk => (
      background: AppColors.atRiskChipBg,
      foreground: AppColors.atRiskText,
    ),
    TaskStatus.overdue => (
      background: AppColors.overdueChipBg,
      foreground: AppColors.overdue,
    ),
    TaskStatus.todo => (
      background: AppColors.todoChipBg,
      foreground: AppColors.todoText,
    ),
  };

  /// Human readable label of [status].
  static String labelFor(TaskStatus status) => switch (status) {
    TaskStatus.onTrack => 'On Track',
    TaskStatus.atRisk => 'At Risk',
    TaskStatus.overdue => 'Overdue',
    TaskStatus.todo => 'To Do',
  };

  @override
  Widget build(BuildContext context) {
    final StatusColors colors = colorsFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        labelFor(status),
        style: AppTextStyles.chip.copyWith(color: colors.foreground),
      ),
    );
  }
}
