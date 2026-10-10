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

  @override
  Widget build(BuildContext context) => ListView(
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
              colors: [Color(0xFF5B3BEA), Color(0xFF9A7BFF)],
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
                      color: Color(0xFF4B2FD0),
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
                style: const TextStyle(color: Color(0xFFEDE8FF)),
              ),
              const SizedBox(height: 4),
              Text(
                member.email,
                style: const TextStyle(color: Color(0xFFEDE8FF), fontSize: 13),
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
                    color: context.colors.violet,
                  ),
                  title: const Text(
                    'Dark theme',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Pure black for comfortable night use.'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                const Divider(height: 1, indent: 72),
                SwitchListTile.adaptive(
                  value: notificationsEnabled,
                  onChanged: onNotificationsChanged,
                  secondary: _IconBox(
                    icon: Icons.notifications_active_rounded,
                    color: context.colors.warning,
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
                  leading: _IconBox(
                    icon: Icons.inbox_rounded,
                    color: context.colors.info,
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
          icon: Icon(Icons.logout_rounded, color: context.colors.danger),
          label: Text(
            'Sign out',
            style: TextStyle(color: context.colors.danger),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: context.colors.danger.withValues(alpha: .5),
            ),
          ),
        ),
      ),
    ],
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
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