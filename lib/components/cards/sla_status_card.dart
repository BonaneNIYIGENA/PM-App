import 'package:flutter/material.dart';

import '../../core/models/task_model.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../chips/status_chip.dart';

/// Tinted card that reports how a task is doing against its SLA.
class SlaStatusCard extends StatelessWidget {
  const SlaStatusCard({super.key, required this.status, required this.message});

  final TaskStatus status;
  final String message;

  static IconData _iconFor(TaskStatus status) => switch (status) {
    TaskStatus.onTrack => Icons.check_circle_outline,
    TaskStatus.atRisk => Icons.warning_amber_rounded,
    TaskStatus.overdue => Icons.error_outline,
    TaskStatus.todo => Icons.schedule,
  };

  @override
  Widget build(BuildContext context) {
    final StatusColors colors = StatusChip.colorsFor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('SLA Status', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Icon(_iconFor(status), size: 18, color: colors.foreground),
              const SizedBox(width: AppSpacing.sm),
              Text(
                StatusChip.labelFor(status),
                style: AppTextStyles.title.copyWith(color: colors.foreground),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}
