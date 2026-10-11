import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';
import '../widgets/member_form_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.member,
    required this.members,
    required this.roles,
    required this.onAddRole,
    required this.tasks,
    required this.onUpdate,
    required this.onSignOut,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.onOpenNotifications,
  });
  final TeamMember member;
  final List<TeamMember> members;
  final List<String> roles;
  final Future<void> Function(String name) onAddRole;
  final List<ProjectTask> tasks;
  final Future<void> Function(TeamMember updated) onUpdate;
  final VoidCallback onSignOut;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onOpenNotifications;

  Future<void> _editProfile(BuildContext context) async {
    final updated = await showFormSheet<TeamMember>(
      context,
      (_) => MemberFormSheet(
        title: 'Edit profile',
        submitLabel: 'Save changes',
        member: member,
        members: members,
        roles: roles,
        onAddRole: onAddRole,
      ),
    );
    if (updated != null) await onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = tasks.where((t) => t.assigneeId == member.id).toList();
    final done = mine.where((t) => t.isCompleted).length;
    final overdue = mine
        .where((t) => SlaService.calculate(t) == SlaStatus.overdue)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
      children: [
        FadeSlideIn(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.navy, AppTheme.teal],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                  child: Container(
                    width: 78,
                    height: 78,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  member.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Stat(value: mine.length, label: 'Assigned'),
                    _Stat(value: done, label: 'Completed'),
                    _Stat(value: overdue, label: 'Overdue'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeSlideIn(
          index: 1,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    onTap: () => _editProfile(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: _IconBox(
                      icon: Icons.edit_outlined,
                      color: scheme.primary,
                    ),
                    title: const Text(
                      'Edit profile',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Change your name, email and role.'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  const Divider(height: 1, indent: 72),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            _IconBox(
                              icon: Icons.palette_outlined,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'App theme',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text('Choose light or dark.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _ThemeToggle(
                          isDark: isDarkMode,
                          onChanged: onDarkModeChanged,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 72),
                  ListTile(
                    onTap: onOpenNotifications,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: const _IconBox(
                      icon: Icons.inbox_rounded,
                      color: AppTheme.teal,
                    ),
                    title: const Text(
                      'Activity & notifications',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('See recent task updates.'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeSlideIn(index: 2, child: _SignOutTile(onTap: onSignOut)),
      ],
    );
  }
}

// Centred soft red button that signs the user out straight away.
class _SignOutTile extends StatelessWidget {
  const _SignOutTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final danger = context.colors.danger;
    return Pressable(
      onTap: onTap,
      borderRadius: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.soft(danger, alpha: .10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: danger, size: 22),
            const SizedBox(width: 10),
            Text(
              'Sign out',
              style: TextStyle(
                color: danger,
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Light / Dark choice, shown as two segments instead of an on/off switch.
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onChanged});
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: false,
          icon: Icon(Icons.light_mode_rounded, size: 18),
          label: Text('Light'),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(Icons.dark_mode_rounded, size: 18),
          label: Text('Dark'),
        ),
      ],
      selected: {isDark},
      onSelectionChanged: (choice) => onChanged(choice.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: dark ? context.colors.violet : AppTheme.ink,
        selectedForegroundColor: dark ? Colors.black : Colors.white,
        foregroundColor: context.scheme.onSurfaceVariant,
        side: BorderSide(color: context.scheme.outlineVariant),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
        ),
      ],
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? .22 : .14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
