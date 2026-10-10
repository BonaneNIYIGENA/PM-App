import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../models/tasks.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.notifications,
    required this.tasks,
    required this.onOpenTask,
    required this.onMarkAllRead,
    required this.onClear,
  });

  final ValueListenable<List<AppNotification>> notifications;
  final List<ProjectTask> tasks;
  final ValueChanged<ProjectTask> onOpenTask;
  final Future<void> Function() onMarkAllRead;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    final alerts = tasks.where((task) {
      final s = SlaService.calculate(task);
      return s == SlaStatus.overdue || s == SlaStatus.atRisk;
    }).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 66,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: AppBackButton(),
        ),
        title: const Text('Notifications'),
        actions: [
          ValueListenableBuilder<List<AppNotification>>(
            valueListenable: notifications,
            builder: (context, items, _) => PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (value) {
                if (value == 'read') onMarkAllRead();
                if (value == 'clear') onClear();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'read',
                  enabled: items.any((n) => !n.isRead),
                  child: const Text('Mark all as read'),
                ),
                PopupMenuItem(
                  value: 'clear',
                  enabled: items.isNotEmpty,
                  child: const Text('Clear activity'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: notifications,
        builder: (context, items, _) {
          if (items.isEmpty && alerts.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'You’re all caught up',
              message: 'Task updates, assignments and deadline alerts will show up here.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (alerts.isNotEmpty) ...[
                const SectionHeader(title: 'Deadline alerts'),
                const SizedBox(height: 8),
                for (var i = 0; i < alerts.length; i++)
                  FadeSlideIn(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AlertTile(
                        task: alerts[i],
                        onTap: () => onOpenTask(alerts[i]),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
              ],
               if (items.isNotEmpty) ...[
                const SectionHeader(title: 'Recent activity'),
                const SizedBox(height: 8),
                for (var i = 0; i < items.length; i++)
                  FadeSlideIn(
                    key: ValueKey(items[i].id),
                    index: i + alerts.length,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ActivityTile(
                        item: items[i],
                        onTap: () {
                          final id = items[i].taskId;
                          for (final task in tasks) {
                            if (task.id == id) {
                              onOpenTask(task);
                              return;
                            }
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.task, required this.onTap});
  final ProjectTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sla = SlaService.calculate(task);
    final color = slaColor(context, sla);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _IconBubble(
            icon: sla == SlaStatus.overdue
                ? Icons.error_outline_rounded
                : Icons.schedule_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
const SizedBox(height: 3),
                Text(
                  sla == SlaStatus.overdue
                      ? 'Overdue · was due ${shortDate(task.deadline)}'
                      : 'Due soon · ${dueChipLabel(task)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.onTap});
  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.type) {
      'created' => (Icons.add_task_rounded, context.colors.info),
      'completed' => (Icons.check_circle_rounded, context.colors.success),
      'reopened' => (Icons.replay_rounded, context.colors.warning),
      'deleted' => (Icons.delete_outline_rounded, context.colors.danger),
      'assigned' => (Icons.person_add_alt_1_rounded, context.colors.pink),
      'alert' => (Icons.notifications_active_rounded, context.colors.warning),
      'team' => (Icons.groups_rounded, context.colors.violet),
      'welcome' => (Icons.waving_hand_rounded, context.colors.violet),
      _ => (Icons.edit_note_rounded, context.colors.violet),
    };
    return AppCard(
      onTap: item.taskId == null ? null : onTap,
      color: item.isRead
          ? null
          : context.soft(context.scheme.primary, alpha: .07),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBubble(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: context.scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: TextStyle(
                    color: context.scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo(item.createdAt),
                  style: TextStyle(
                    color: context.scheme.onSurfaceVariant.withValues(
                      alpha: .8,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: context.soft(color, alpha: context.isDark ? .22 : .14),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: color, size: 22),
  );
}
