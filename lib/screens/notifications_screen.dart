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
