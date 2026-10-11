import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import 'common.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.member,
    required this.onTap,
    required this.onToggle,
  });

  final ProjectTask task;
  final TeamMember? member;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final sla = SlaService.calculate(task);
    final done = task.isCompleted;
    final muted = context.scheme.onSurfaceVariant;
    final priority = priorityColor(context, task.priority);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CheckCircle(
            done: done,
            onTap: () {
              HapticFeedback.lightImpact();
              onToggle();
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: done ? muted : context.scheme.onSurface,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: muted,
                  ),
                  child: Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SlaBadge(status: sla),
                    _Tag(
                      icon: Icons.event_outlined,
                      label: dueChipLabel(task),
                      color: sla == SlaStatus.overdue
                          ? context.colors.danger
                          : muted,
                    ),
                    _Tag(
                      icon: Icons.flag_rounded,
                      label: task.priority,
                      color: priority,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: member?.name ?? 'Unassigned',
            child: MemberAvatar(member: member, radius: 16),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done, required this.onTap});
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final success = context.colors.success;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Semantics(
          button: true,
          label: done ? 'Reopen task' : 'Mark task complete',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? success : Colors.transparent,
              border: Border.all(
                color: done ? success : context.scheme.outline,
                width: 2,
              ),
            ),
            child: AnimatedScale(
              scale: done ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: context.isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
