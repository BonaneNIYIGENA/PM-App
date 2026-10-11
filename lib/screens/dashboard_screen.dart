import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';
import '../widgets/task_card.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.tasks,
    required this.members,
    required this.onOpenTask,
    required this.onToggleTask,
    required this.onAddTask,
    required this.onShowTasks,
  });

  final List<ProjectTask> tasks;
  final List<TeamMember> members;
  final ValueChanged<ProjectTask> onOpenTask;
  final ValueChanged<ProjectTask> onToggleTask;
  final VoidCallback onAddTask;
  final ValueChanged<String> onShowTasks;

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.isCompleted).length;
    final overdue = tasks
        .where((task) => SlaService.calculate(task) == SlaStatus.overdue)
        .length;
    final atRisk = tasks
        .where((task) => SlaService.calculate(task) == SlaStatus.atRisk)
        .length;
    final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;
    final attention = tasks.where((task) {
      final status = SlaService.calculate(task);
      return status == SlaStatus.overdue || status == SlaStatus.atRisk;
    }).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
      children: [
        FadeSlideIn(
          child: _HeroCard(
            progress: progress,
            completed: completed,
            total: tasks.length,
            onInsights: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StatisticsScreen(tasks: tasks)),
            ),
          ),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(index: 1, child: const SectionHeader(title: 'Overview')),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            FadeSlideIn(
              index: 2,
              child: _StatTile(
                label: 'All tasks',
                value: tasks.length,
                icon: Icons.grid_view_rounded,
                color: context.colors.violet,
                onTap: () => onShowTasks('All'),
              ),
            ),
            FadeSlideIn(
              index: 3,
              child: _StatTile(
                label: 'Completed',
                value: completed,
                icon: Icons.check_circle_rounded,
                color: context.colors.success,
                onTap: () => onShowTasks('Completed'),
              ),
            ),
            FadeSlideIn(
              index: 4,
              child: _StatTile(
                label: 'At risk',
                value: atRisk,
                icon: Icons.schedule_rounded,
                color: context.colors.warning,
                onTap: () => onShowTasks('At risk'),
              ),
            ),
            FadeSlideIn(
              index: 5,
              child: _StatTile(
                label: 'Overdue',
                value: overdue,
                icon: Icons.error_rounded,
                color: context.colors.danger,
                onTap: () => onShowTasks('Overdue'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionHeader(
          title: 'Needs attention',
          actionLabel: 'See all',
          onAction: () => onShowTasks('All'),
        ),
        const SizedBox(height: 6),
        if (attention.isEmpty)
          AppCard(
            child: Row(
              children: [
                Icon(
                  tasks.isEmpty
                      ? Icons.inbox_outlined
                      : Icons.celebration_rounded,
                  color: context.colors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tasks.isEmpty
                        ? 'Tap + to add your first task.'
                        : 'Everything is on track. Nice work!',
                  ),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < attention.take(4).length; i++)
            FadeSlideIn(
              key: ValueKey(attention[i].id),
              index: i + 6,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskCard(
                  task: attention[i],
                  member: memberFor(members, attention[i].assigneeId),
                  onTap: () => onOpenTask(attention[i]),
                  onToggle: () => onToggleTask(attention[i]),
                ),
              ),
            ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.progress,
    required this.completed,
    required this.total,
    required this.onInsights,
  });
  final double progress;
  final int completed;
  final int total;
  final VoidCallback onInsights;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5B3BEA), Color(0xFF9A7BFF)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6C4CF1)
              .withValues(alpha: context.isDark ? .25 : .35),
          blurRadius: 26,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sprint delivery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$completed of $total tasks completed',
                style: const TextStyle(color: Color(0xFFEDE8FF), height: 1.3),
              ),
              const SizedBox(height: 16),
              Pressable(
                borderRadius: 20,
                onTap: onInsights,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: Color(0xFF4B2FD0),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'View insights',
                        style: TextStyle(
                          color: Color(0xFF4B2FD0),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    borderRadius: 24,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.soft(color, alpha: context.isDark ? .16 : .14),
        borderRadius: BorderRadius.circular(24),
        border: context.isDark
            ? Border.all(color: color.withValues(alpha: .25))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Icon(Icons.arrow_outward_rounded, size: 18, color: color),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => Text(
                  '${v.round()}',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: context.scheme.onSurface,
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
