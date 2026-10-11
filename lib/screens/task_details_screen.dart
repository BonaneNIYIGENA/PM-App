import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.members,
    required this.onEdit,
    required this.onUpdate,
    required this.onDelete,
  });
  final ProjectTask task;
  final List<TeamMember> members;
  final Future<ProjectTask?> Function(ProjectTask current) onEdit;
  final Future<void> Function(ProjectTask previous, ProjectTask updated)
  onUpdate;
  final Future<void> Function(ProjectTask task) onDelete;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late ProjectTask _task;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _edit() async {
    final updated = await widget.onEdit(_task);
    if (updated != null && mounted) setState(() => _task = updated);
  }

  Future<void> _setStatus(String status) async {
    if (_working || status == _task.status) return;
    setState(() => _working = true);
    final updated = _task.copyWith(status: status);
    try {
      await widget.onUpdate(_task, updated);
      if (mounted) setState(() => _task = updated);
    } catch (_) {
      // The parent shows an error message when persistence fails.
    }
    if (mounted) setState(() => _working = false);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this task?'),
        content: const Text('This task will be removed from the project.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.danger,
              foregroundColor: context.scheme.onError,
              minimumSize: const Size(96, 44),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.onDelete(_task);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      // The parent shows an error message when persistence fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignee = memberFor(widget.members, _task.assigneeId);
    final sla = SlaService.calculate(_task);
    final done = _task.isCompleted;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 66,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: AppBackButton(),
        ),
        title: const Text('Task details'),
        actions: [
          RoundIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'Edit task',
            onTap: _edit,
          ),
          const SizedBox(width: 8),
          RoundIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete task',
            color: context.colors.danger,
            onTap: _delete,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                SlaBadge(status: sla),
                const SizedBox(width: 10),
                _PriorityPill(priority: _task.priority),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            index: 1,
            child: Text(
              _task.title,
              style: context.text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeSlideIn(
            index: 2,
            child: _StatusSelector(
              value: _task.status,
              enabled: !_working,
              onChanged: _setStatus,
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            index: 3,
            child: AppCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Assigned to',
                    value: assignee?.name ?? 'Unassigned',
                    leading: MemberAvatar(member: assignee, radius: 13),
                  ),
                  const Divider(height: 26),
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: 'Deadline',
                    value: formatDate(_task.deadline),
                  ),
                  const Divider(height: 26),
                  _DetailRow(
                    icon: Icons.flag_outlined,
                    label: 'Status',
                    value: taskStatusLabel(_task.status),
                  ),
                  const Divider(height: 26),
                  _DetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Created',
                    value: formatDate(_task.createdAt),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeSlideIn(
            index: 4,
            child: const SectionHeader(title: 'Description'),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            index: 5,
            child: AppCard(
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _task.description.isEmpty
                      ? 'No description provided.'
                      : _task.description,
                  style: TextStyle(
                    height: 1.55,
                    fontSize: 15,
                    color: _task.description.isEmpty
                        ? context.scheme.onSurfaceVariant
                        : context.scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          FadeSlideIn(
            index: 6,
            child: FilledButton.icon(
              onPressed: _working
                  ? null
                  : () => _setStatus(done ? 'todo' : 'completed'),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  done ? Icons.undo_rounded : Icons.check_rounded,
                  key: ValueKey(done),
                ),
              ),
              label: Text(done ? 'Reopen task' : 'Mark as complete'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(context, priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.soft(color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$priority priority',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('todo', 'To do'),
    ('inProgress', 'In progress'),
    ('completed', 'Completed'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: context.scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        for (final (key, label) in _options)
          Expanded(
            child: Pressable(
              borderRadius: 14,
              scale: .96,
              onTap: enabled ? () => onChanged(key) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == key
                      ? context.scheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: value == key
                        ? context.scheme.onPrimary
                        : context.scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.leading,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: context.scheme.onSurfaceVariant),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: context.scheme.onSurfaceVariant),
        ),
      ),
      if (leading != null) ...[leading!, const SizedBox(width: 8)],
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
