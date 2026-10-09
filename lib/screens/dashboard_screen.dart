import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.tasks,
    required this.members,
    required this.currentMember,
    required this.onOpenTask,
    required this.onAddTask,
    required this.onShowTasks,
  });

  final List<ProjectTask> tasks;
  final List<TeamMember> members;
  final TeamMember currentMember;
  final ValueChanged<ProjectTask> onOpenTask;
  final VoidCallback onAddTask;
  final VoidCallback onShowTasks;

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

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROJECT OVERVIEW',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                letterSpacing: 1.3,
                                color: Colors.black54,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Good day, ${currentMember.name.split(' ').first}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink,
                              ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFFE4EBFA),
                    child: Text(
                      currentMember.initials,
                      style: const TextStyle(
                        color: AppTheme.navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: AppTheme.navy,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Task progress',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StatisticsScreen(tasks: tasks),
                              ),
                            ),
                            icon: const Icon(
                              Icons.insights_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'View statistics',
                          ),
                        ],
                      ),
                      Text(
                        '${(progress * 100).round()}% complete',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: Colors.white24,
                          color: const Color(0xFF73D7C7),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '$completed of ${tasks.length} tasks completed',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'All tasks',
                      value: '${tasks.length}',
                      icon: Icons.grid_view_rounded,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Completed',
                      value: '$completed',
                      icon: Icons.check_circle_outline,
                      color: AppTheme.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'At risk',
                      value: '$atRisk',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFC47A13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'Overdue',
                      value: '$overdue',
                      icon: Icons.error_outline_rounded,
                      color: const Color(0xFFCB4B51),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Needs attention',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton(
                    onPressed: onShowTasks,
                    child: const Text('All tasks'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (attention.isEmpty)
                _EmptyCard(
                  icon: Icons.check_circle_outline,
                  message: tasks.isEmpty
                      ? 'Add a task to see project work here.'
                      : 'Everything is on track. Nice work!',
                )
              else
                ...attention
                    .take(3)
                    .map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _TaskAttentionTile(
                          task: task,
                          member: _memberFor(members, task.assigneeId),
                          onTap: () => onOpenTask(task),
                        ),
                      ),
                    ),
              const SizedBox(height: 8),
              if (tasks.isEmpty)
                FilledButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Create your first task'),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _TaskAttentionTile extends StatelessWidget {
  const _TaskAttentionTile({
    required this.task,
    required this.member,
    required this.onTap,
  });
  final ProjectTask task;
  final TeamMember? member;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      title: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${member?.name ?? 'Unassigned'}  ·  Due ${_shortDate(task.deadline)}',
      ),
      trailing: SlaBadge(status: SlaService.calculate(task)),
    ),
  );
}

class SlaBadge extends StatelessWidget {
  const SlaBadge({super.key, required this.status});
  final SlaStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SlaStatus.onTrack => const Color(0xFF20826F),
      SlaStatus.atRisk => const Color(0xFFB66C0C),
      SlaStatus.overdue => const Color(0xFFBB414A),
      SlaStatus.completed => const Color(0xFF526A9C),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        SlaService.label(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.teal),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

String _shortDate(DateTime date) => '${date.day}/${date.month}';

TeamMember? _memberFor(List<TeamMember> members, int? id) {
  for (final member in members) {
    if (member.id == id) return member;
  }
  return null;
}
