import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import 'common.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.member,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
  });

  final ProjectTask task;
  final TeamMember? member;
  // Opens the full details screen (button inside the expanded card).
  final VoidCallback onTap;
  // Opens the edit sheet for this task.
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _expanded = false;

  ProjectTask get task => widget.task;

  Widget _details(BuildContext context) {
    final member = widget.member;
    final muted = context.scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.description.isEmpty
                ? 'No description added.'
                : task.description,
            style: TextStyle(color: muted, height: 1.4),
          ),
          const SizedBox(height: 14),
          InfoLine(
            icon: Icons.person_outline_rounded,
            label: 'Assigned to',
            value: member == null
                ? 'Unassigned'
                : '${member.name} · ${member.role}',
          ),
          InfoLine(
            icon: Icons.event_outlined,
            label: 'Deadline',
            value: formatDate(task.deadline),
          ),
          InfoLine(
            icon: Icons.flag_outlined,
            label: 'Priority',
            value: task.priority,
          ),
          InfoLine(
            icon: Icons.timelapse_rounded,
            label: 'Status',
            value: taskStatusLabel(task.status),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: widget.onTap,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open task'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sla = SlaService.calculate(task);
    final done = task.isCompleted;
    final muted = context.scheme.onSurfaceVariant;
    final priority = priorityColor(context, task.priority);
    final banner = slaColor(context, sla);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CheckCircle(
          done: done,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onToggle();
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
          message: widget.member?.name ?? 'Unassigned',
          child: MemberAvatar(member: widget.member, radius: 16),
        ),
      ],
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: _details(context),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
    return _BannerCard(
      color: banner,
      onTap: () => setState(() => _expanded = !_expanded),
      child: content,
    );
  }
}

// A card with a colored strip on its left edge that shows the SLA status.
class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.color,
    required this.onTap,
    required this.child,
  });
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = 20.0;
    return Pressable(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: context.scheme.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: context.scheme.outlineVariant),
          boxShadow: context.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 1),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
                child: child,
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: ColoredBox(color: color),
              ),
            ],
          ),
        ),
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