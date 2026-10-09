import 'package:flutter/material.dart';

import '../components/components.dart';
import '../core/mock/mock_data.dart';
import '../core/models/activity_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Home tab: greeting, project summary and the recent activity feed.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const StatCard _totalTasks = StatCard(
    icon: Icons.assignment_outlined,
    iconColor: AppColors.statTotalFg,
    background: AppColors.statTotalBg,
    value: dashboardTotalTasks,
    label: 'Total Tasks',
  );

  static const StatCard _onTrack = StatCard(
    icon: Icons.check_circle_outline,
    iconColor: AppColors.onTrack,
    background: AppColors.onTrackBg,
    value: dashboardOnTrack,
    label: 'On Track',
  );

  static const StatCard _atRisk = StatCard(
    icon: Icons.warning_amber_rounded,
    iconColor: AppColors.atRisk,
    background: AppColors.atRiskBg,
    value: dashboardAtRisk,
    label: 'At Risk',
  );

  static const StatCard _overdue = StatCard(
    icon: Icons.error_outline,
    iconColor: AppColors.overdue,
    background: AppColors.overdueBg,
    value: dashboardOverdue,
    label: 'Overdue',
  );

  /// Two stat cards side by side, stretched to a shared height.
  Widget _statRow(StatCard left, StatCard right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: left),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: right),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Dashboard',
        leading: IconButton(
          // TODO: open the navigation drawer once it exists.
          onPressed: () {},
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
        ),
        trailing: const UserAvatar.onPrimary(initials: 'JD'),
      ),
      floatingActionButton: AppFab(
        // TODO: open the create-task flow.
        onPressed: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSizes.fabClearance,
        ),
        children: <Widget>[
          Text('Good morning, John', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Here's what's happening with your project.",
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          _statRow(_totalTasks, _onTrack),
          const SizedBox(height: AppSpacing.md),
          _statRow(_atRisk, _overdue),
          const SizedBox(height: AppSpacing.lg),
          TaskOverviewCard(
            counts: taskOverviewStatusCounts,
            completed: dashboardCompleted,
            total: dashboardTotalTasks,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('Recent Activity'),
          const SizedBox(height: AppSpacing.lg),
          for (final ActivityModel activity in mockActivities) ...<Widget>[
            ActivityTile(activity: activity),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}
