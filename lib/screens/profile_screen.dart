import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.member,
    required this.onSignOut,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onOpenNotifications,
  });
  final TeamMember member;
  final VoidCallback onSignOut;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onOpenNotifications;

  static const _warning = Color(0xFFE0A21B);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                  SwitchListTile.adaptive(
                    value: isDarkMode,
                    onChanged: onDarkModeChanged,
                    secondary: _IconBox(
                      icon: isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: scheme.primary,
                    ),
                    title: const Text(
                      'Dark theme',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Easier on the eyes at night.'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  const Divider(height: 1, indent: 72),
                  SwitchListTile.adaptive(
                    value: notificationsEnabled,
                    onChanged: onNotificationsChanged,
                    secondary: const _IconBox(
                      icon: Icons.notifications_active_rounded,
                      color: _warning,
                    ),
                    title: const Text(
                      'Deadline reminders',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Device alerts before a task is due.'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
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
        FadeSlideIn(
          index: 2,
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            icon: Icon(Icons.logout_rounded, color: scheme.error),
            label: Text('Sign out', style: TextStyle(color: scheme.error)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: scheme.error.withValues(alpha: .5)),
            ),
          ),
        ),
      ],
    );
  }
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
