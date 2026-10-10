import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({
    super.key,
    required this.members,
    required this.tasks,
    required this.onSave,
    required this.onDelete,
  });
  final List<TeamMember> members;
  final List<ProjectTask> tasks;
  final Future<void> Function(TeamMember member) onSave;
  final Future<void> Function(TeamMember member) onDelete;

  Future<void> _editMember(BuildContext context, [TeamMember? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final formKey = GlobalKey<FormState>();
    final roles = [
      'Project lead',
      'Flutter developer',
      'UI designer',
      'QA engineer',
      'Team member',
    ];
    var role = existing?.role ?? roles.last;
    final saved = await showDialog<TeamMember>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existing == null ? 'Add team member' : 'Edit team member',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) =>
                        value == null || value.trim().length < 2
                        ? 'Enter the member’s name.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Enter an email address.';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(email)) {
                        return 'Enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: roles.contains(role) ? role : roles.last,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: roles
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => role = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final name = nameController.text.trim();
                final initials = name
                    .split(RegExp(r'\s+'))
                    .take(2)
                    .map((part) => part[0])
                    .join()
                    .toUpperCase();
                Navigator.pop(
                  dialogContext,
                  TeamMember(
                    id: existing?.id,
                    name: name,
                    role: role,
                    email: emailController.text.trim(),
                    initials: initials,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    emailController.dispose();
    if (saved != null) await onSave(saved);
  }

  Future<void> _confirmDelete(BuildContext context, TeamMember member) async {
    final assigned = tasks.where((task) => task.assigneeId == member.id).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove team member?'),
        content: Text(
          assigned == 0
              ? 'This profile will be removed.'
              : '$assigned task(s) will become unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDelete(member);
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
    children: [
      FadeSlideIn(
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${members.length} ${members.length == 1 ? 'person' : 'people'} in your workspace',
                style: TextStyle(color: context.scheme.onSurfaceVariant),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _editMember(context),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                backgroundColor: context.soft(
                  context.scheme.primary,
                  alpha: .16,
                ),
                foregroundColor: context.scheme.primary,
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
              openTasks: tasks
                  .where((t) => t.assigneeId == members[i].id && !t.isCompleted)
                  .length,
              totalTasks: tasks
                  .where((t) => t.assigneeId == members[i].id)
                  .length,
              onEdit: () => _editMember(context, members[i]),
              onDelete: () => _confirmDelete(context, members[i]),
            ),
          ),
        ),
    ],
  );
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.openTasks,
    required this.totalTasks,
    required this.onEdit,
    required this.onDelete,
  });
  final TeamMember member;
  final int openTasks;
  final int totalTasks;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = totalTasks == 0 ? 0.0 : (totalTasks - openTasks) / totalTasks;
    return AppCard(
      onTap: onEdit,
      child: Row(
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
                  style: TextStyle(color: context.scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: done),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, _) => LinearProgressIndicator(
                            value: v,
                            minHeight: 6,
                            color: context.colors.success,
                            backgroundColor: context.soft(
                              context.colors.success,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$openTasks open',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: context.scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Options',
            icon: Icon(
              Icons.more_vert_rounded,
              color: context.scheme.onSurfaceVariant,
            ),
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }
}