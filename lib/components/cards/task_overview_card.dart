import 'package:flutter/material.dart';

import '../../core/models/task_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../charts/task_donut_chart.dart';
import '../chips/status_chip.dart';

/// White card holding the donut chart and its legend.
class TaskOverviewCard extends StatelessWidget {
  const TaskOverviewCard({
    super.key,
    required this.counts,
    required this.completed,
    required this.total,
  });

  /// Number of tasks per status, rendered in iteration order.
  final Map<TaskStatus, int> counts;

  /// Completed tasks are not a [TaskStatus], so they are passed separately and
  /// appended as the last legend row.
  final int completed;

  /// Total number of tasks shown in the middle of the donut.
  final int total;

  /// Colour of the donut slice that represents [status].
  static Color _chartColorFor(TaskStatus status) => switch (status) {
    TaskStatus.onTrack => AppColors.chartOnTrack,
    TaskStatus.atRisk => AppColors.chartAtRisk,
    TaskStatus.overdue => AppColors.chartOverdue,
    // The donut has no "To Do" slice; fall back to the neutral hue.
    TaskStatus.todo => AppColors.chartCompleted,
  };

  @override
  Widget build(BuildContext context) {
    final List<_LegendEntry> entries = <_LegendEntry>[
      for (final MapEntry<TaskStatus, int> entry in counts.entries)
        _LegendEntry(
          label: StatusChip.labelFor(entry.key),
          color: _chartColorFor(entry.key),
          value: entry.value,
        ),
      _LegendEntry(
        label: 'Completed',
        color: AppColors.chartCompleted,
        value: completed,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Task Overview', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              TaskDonutChart(
                segments: <DonutSegment>[
                  for (final _LegendEntry entry in entries)
                    DonutSegment(color: entry.color, value: entry.value),
                ],
                total: total,
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final _LegendEntry entry in entries)
                      _LegendRow(entry: entry),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendEntry {
  const _LegendEntry({
    required this.label,
    required this.color,
    required this.value,
  });

  final String label;
  final Color color;
  final int value;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.entry});

  final _LegendEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: entry.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.label,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${entry.value}',
            style: AppTextStyles.chip.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
