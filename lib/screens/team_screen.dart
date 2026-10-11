import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';
import '../widgets/member_form_sheet.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({
    super.key,
    required this.members,
    required this.roles,
    required this.onAddRole,
    required this.tasks,
    required this.onSave,
    required this.onDelete,
  });
  final List<TeamMember> members;
  final List<String> roles;
  final Future<void> Function(String name) onAddRole;
  final List<ProjectTask> tasks;
  final Future<void> Function(TeamMember member) onSave;
  final Future<void> Function(TeamMember member) onDelete;

  Future<void> _editMember(BuildContext context, [TeamMember? existing]) async {
    final saved = await showFormSheet<TeamMember>(
      context,
      (_) => MemberFormSheet(
        title: existing == null ? 'Add team member' : 'Edit team member',
        submitLabel: existing == null ? 'Add member' : 'Save changes',
        member: existing,
        members: members,
        roles: roles,
        onAddRole: onAddRole,
      ),
    );
    if (saved != null) await onSave(saved);
  }

  Future<void> _confirmDelete(BuildContext context, TeamMember member) async {
    // Last-member guard: the workspace must always keep at least one person
    if (members.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can’t remove the last team member.')),
      );
      return;
    }
    final assigned = tasks.where((task) => task.assigneeId == member.id).length;
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.person_remove_outlined,
      title: 'Remove ${member.name}?',
      message: assigned == 0
          ? 'They will be deleted from the workspace and will need to create '
                'a new account to sign in again.'
          : 'They will be deleted and need to create a new account to sign in '
                'again. $assigned task(s) will become unassigned.',
      confirmLabel: 'Remove',
    );
    if (confirmed) await onDelete(member);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
      children: [
        FadeSlideIn(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${members.length} ${members.length == 1 ? 'person' : 'people'} in your workspace',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _editMember(context),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  backgroundColor: scheme.primary.withValues(alpha: .16),
                  foregroundColor: scheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (members.isEmpty)
          const EmptyState(
            icon: Icons.groups_outlined,
            title: 'No team members yet',
            message: 'Add someone to assign tasks.',
          ),
        for (var i = 0; i < members.length; i++)
          FadeSlideIn(
            key: ValueKey(members[i].id),
            index: i + 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MemberCard(
                member: members[i],
                tasks: tasks
                    .where((t) => t.assigneeId == members[i].id)
                    .toList(),
                onEdit: () => _editMember(context, members[i]),
                onDelete: () => _confirmDelete(context, members[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _MemberCard extends StatefulWidget {
  const _MemberCard({
    required this.member,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
  });
  final TeamMember member;
  final List<ProjectTask> tasks;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _expanded = false;

  Widget _details(BuildContext context) {
    final member = widget.member;
    final muted = context.scheme.onSurfaceVariant;
    final shown = widget.tasks.take(4).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLine(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: member.email,
          ),
          InfoLine(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: member.role,
          ),
          const SizedBox(height: 4),
          Text(
            'Assigned tasks',
            style: TextStyle(
              color: muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            Text('No tasks assigned yet.', style: TextStyle(color: muted))
          else
            for (final task in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: slaColor(context, SlaService.calculate(task)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      shortDate(task.deadline),
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
          if (widget.tasks.length > shown.length)
            Text(
              '+ ${widget.tasks.length - shown.length} more',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: widget.onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.danger,
                ),
                icon: const Icon(Icons.person_remove_outlined, size: 18),
                label: const Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final member = widget.member;
    return AppCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MemberAvatar(member: member, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.role,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    _StatusBar(tasks: widget.tasks),
                  ],
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _details(context)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// One bar split by SLA status, so the colors show how a person's tasks stand.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.tasks});
  final List<ProjectTask> tasks;

  static const _order = [
    SlaStatus.completed,
    SlaStatus.onTrack,
    SlaStatus.atRisk,
    SlaStatus.overdue,
  ];

  @override
  Widget build(BuildContext context) {
    final counts = {for (final status in _order) status: 0};
    for (final task in tasks) {
      final status = SlaService.calculate(task);
      counts[status] = counts[status]! + 1;
    }
    final present = [
      for (final status in _order)
        if (counts[status]! > 0) status,
    ];

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 8,
        child: present.isEmpty
            ? ColoredBox(
                color: context.scheme.outlineVariant,
                child: const SizedBox.expand(),
              )
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: v,
                    child: Row(
                      children: [
                        for (final status in present)
                          Expanded(
                            flex: counts[status]!,
                            child: ColoredBox(
                              color: slaColor(context, status),
                              child: const SizedBox.expand(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bar,
        if (present.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final status in present)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: slaColor(context, status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${counts[status]} ${SlaService.label(status).toLowerCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}
