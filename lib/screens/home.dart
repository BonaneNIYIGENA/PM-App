import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/notifications_service.dart';
import '../services/sla_service.dart';
import '../services/storage.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';
import '../widgets/floating_nav_bar.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';
import 'tasks_screen.dart';
import 'team_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService.instance;
  final _activities = ValueNotifier<List<AppNotification>>([]);
  List<ProjectTask> _tasks = [];
  List<TeamMember> _members = [];
  TeamMember? _currentMember;
  int _tab = 0;
  String _taskFilter = 'All';
  bool _loading = true;
  bool _notificationsEnabled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _activities.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _storage.loadTasks(),
        _storage.loadMembers(),
        _storage.loadNotificationsEnabled(),
        _storage.loadActivities(),
        _storage.loadSessionEmail(),
      ]);
      if (!mounted) return;
      final members = results[1] as List<TeamMember>;
      final sessionEmail = (results[4] as String?)?.toLowerCase();
      TeamMember? restored;
      if (sessionEmail != null) {
        for (final member in members) {
          if (member.email.trim().toLowerCase() == sessionEmail) {
            restored = member;
            break;
          }
        }
      }
      _activities.value = results[3] as List<AppNotification>;
      setState(() {
        _tasks = results[0] as List<ProjectTask>;
        _members = members;
        _notificationsEnabled = results[2] as bool;
        _currentMember = restored;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not open the local database. $error';
      });
    }
  }

  Future<void> _refresh() async {
    final tasks = await _storage.loadTasks();
    final members = await _storage.loadMembers();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _members = members;
      if (_currentMember != null) {
        _currentMember = memberFor(members, _currentMember!.id);
      }
    });
  }

  String get _actor => _currentMember?.name.split(' ').first ?? 'Someone';

  Future<void> _log(
    String type,
    String title,
    String body, {
    int? taskId,
  }) async {
    try {
      await _storage.addActivity(
        AppNotification(
          type: type,
          title: title,
          body: body,
          taskId: taskId,
          createdAt: DateTime.now(),
        ),
      );
      _activities.value = await _storage.loadActivities();
    } catch (_) {
      // Activity is a convenience; never block the action that triggered it.
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _storage.markAllActivitiesRead();
      _activities.value = await _storage.loadActivities();
    } catch (_) {}
  }

  Future<void> _clearActivity() async {
    try {
      await _storage.clearActivities();
      _activities.value = [];
    } catch (_) {}
  }

  void _toast(String message, {IconData icon = Icons.check_circle_rounded}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, size: 20, color: context.colors.success),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        ),
      );
  }

  Future<ProjectTask?> _createOrEditTask([ProjectTask? task]) async {
    final saved = await Navigator.of(context).push<ProjectTask>(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task, members: _members),
      ),
    );
    if (saved == null) return null;
    try {
      final id = await _storage.saveTask(saved);
      await _refresh();
      final stored = saved.copyWith(id: saved.id ?? id);
      final assignee = memberFor(_members, stored.assigneeId);
      if (task == null) {
        await _log(
          'created',
          'Task created',
          '$_actor created “${stored.title}”'
              '${assignee == null ? '' : ' and assigned it to ${assignee.name}'}.',
          taskId: stored.id,
        );
        _toast('Task created');
      } else {
        await _log(
          'updated',
          'Task updated',
          '$_actor updated “${stored.title}”.',
          taskId: stored.id,
        );
        if (task.assigneeId != stored.assigneeId && assignee != null) {
          await _log(
            'assigned',
            'Task assigned',
            '“${stored.title}” was assigned to ${assignee.name}.',
            taskId: stored.id,
          );
        }
        _toast('Changes saved');
      }
      if (_notificationsEnabled) {
        try {
          await NotificationsService.remindAboutTask(stored);
        } catch (_) {
          _showStorageError('set a reminder for the task');
        }
      }
      return stored;
    } catch (_) {
      _showStorageError('save the task');
      return null;
    }
  }

  Future<void> _updateTask(ProjectTask previous, ProjectTask updated) async {
    try {
      await _storage.saveTask(updated);
      if (previous.status != updated.status) {
        if (updated.isCompleted) {
          await _log(
            'completed',
            'Task completed',
            '$_actor completed “${updated.title}”.',
            taskId: updated.id,
          );
        } else if (previous.isCompleted) {
          await _log(
            'reopened',
            'Task reopened',
            '$_actor reopened “${updated.title}”.',
            taskId: updated.id,
          );
        } else {
          await _log(
            'updated',
            'Status changed',
            '“${updated.title}” moved to ${taskStatusLabel(updated.status)}.',
            taskId: updated.id,
          );
        }
      }
      if (_notificationsEnabled) {
        try {
          if (updated.isCompleted) {
            await NotificationsService.cancelTaskReminder(updated);
          } else {
            await NotificationsService.remindAboutTask(updated);
          }
        } catch (_) {
          _showStorageError('update the task reminder');
        }
      }
      await _refresh();
    } catch (_) {
      _showStorageError('update the task');
      rethrow;
    }
  }

  Future<void> _toggleTask(ProjectTask task) async {
    final updated = task.copyWith(
      status: task.isCompleted ? 'todo' : 'completed',
    );
    try {
      await _updateTask(task, updated);
      _toast(updated.isCompleted ? 'Marked as complete' : 'Task reopened');
    } catch (_) {
      // _updateTask already reported the error.
    }
  }

  Future<void> _deleteTask(ProjectTask task) async {
    try {
      await _storage.deleteTask(task.id!);
      try {
        await NotificationsService.cancelTaskReminder(task);
      } catch (_) {
        // The task should still be deleted if notifications fail.
      }
      await _log('deleted', 'Task deleted', '$_actor deleted “${task.title}”.');
      await _refresh();
      _toast('Task deleted', icon: Icons.delete_outline_rounded);
    } catch (_) {
      _showStorageError('delete the task');
      rethrow;
    }
  }

  Future<void> _openTask(ProjectTask task) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(
          task: task,
          members: _members,
          onEdit: _createOrEditTask,
          onUpdate: _updateTask,
          onDelete: _deleteTask,
        ),
      ),
    );
    await _refresh();
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          notifications: _activities,
          tasks: _tasks,
          onOpenTask: _openTask,
          onMarkAllRead: _markAllRead,
          onClear: _clearActivity,
        ),
      ),
    );
    await _markAllRead();
  }

  Future<void> _saveMember(TeamMember member) async {
    final email = member.email.trim().toLowerCase();
    final duplicate = _members.any(
      (m) => m.id != member.id && m.email.trim().toLowerCase() == email,
    );
    if (duplicate) {
      _toast(
        'A member with that email already exists.',
        icon: Icons.error_outline_rounded,
      );
      return;
    }
    try {
      final isNew = member.id == null;
      await _storage.saveMember(member);
      await _refresh();
      await _log(
        'team',
        isNew ? 'Teammate added' : 'Teammate updated',
        isNew
            ? '${member.name} joined the workspace as ${member.role}.'
            : '${member.name}’s profile was updated.',
      );
      _toast(isNew ? 'Member added' : 'Member updated');
    } catch (_) {
      _showStorageError('save the team member');
    }
  }

  Future<void> _deleteMember(TeamMember member) async {
    if (member.id == null) return;
    if (_members.length <= 1) {
      _toast(
        'Keep at least one team member in the workspace.',
        icon: Icons.info_outline_rounded,
      );
      return;
    }
    try {
      await _storage.deleteMember(member.id!);
      final wasCurrent = _currentMember?.id == member.id;
      await _refresh();
      await _log('team', 'Teammate removed', '${member.name} was removed.');
      if (wasCurrent) await _signOut();
    } catch (_) {
      _showStorageError('remove the team member');
    }
  }

  Future<void> _signIn(TeamMember member) async {
    try {
      await _storage.saveSessionEmail(member.email.trim().toLowerCase());
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _currentMember = member;
      _tab = 0;
    });
    final overdue = _tasks
        .where((t) => SlaService.calculate(t) == SlaStatus.overdue)
        .length;
    final atRisk = _tasks
        .where((t) => SlaService.calculate(t) == SlaStatus.atRisk)
        .length;
    if (overdue + atRisk > 0) {
      final body =
          'You have $overdue overdue and $atRisk at-risk '
          '${overdue + atRisk == 1 ? 'task' : 'tasks'}.';
      final last = _activities.value.isEmpty ? null : _activities.value.first;
      if (last == null || last.type != 'alert' || last.body != body) {
        await _log('alert', 'Deadline alerts', body);
      }
    }
  }

  Future<void> _registerAccount(String name, String email, String role) async {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    try {
      await _storage.saveMember(
        TeamMember(name: name, role: role, email: email, initials: initials),
      );
      await _refresh();
      final created = _members.firstWhere(
        (m) => m.email.trim().toLowerCase() == email.trim().toLowerCase(),
      );
      await _log(
        'welcome',
        'Welcome to taskMS',
        'Your account is ready, ${name.split(' ').first}. Tap + to add your first task.',
      );
      await _signIn(created);
    } catch (_) {
      _showStorageError('create your account');
    }
  }

  Future<void> _signOut() async {
    try {
      await _storage.saveSessionEmail(null);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _currentMember = null;
      _tab = 0;
    });
  }

  Future<void> _setNotificationsEnabled(bool enabled) async {
    try {
      if (enabled) {
        final granted = await NotificationsService.requestPermission();
        if (!granted) {
          _toast(
            'Notification permission was not granted.',
            icon: Icons.notifications_off_outlined,
          );
          return;
        }
      } else {
        await NotificationsService.cancelAllReminders();
      }
      await _storage.saveNotificationsEnabled(enabled);
      if (mounted) setState(() => _notificationsEnabled = enabled);
    } catch (_) {
      _toast(
        'Could not update notification settings.',
        icon: Icons.error_outline_rounded,
      );
    }
  }

  void _showStorageError(String action) {
    _toast(
      'Could not $action. Please try again.',
      icon: Icons.error_outline_rounded,
    );
  }

  void _showTasks(String filter) => setState(() {
    _taskFilter = filter;
    _tab = 1;
  });

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: context.scheme.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.storage_rounded,
          title: 'Something went wrong',
          message: _error!,
          actionLabel: 'Try again',
          onAction: () {
            setState(() => _loading = true);
            _loadData();
          },
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      child: _currentMember == null
          ? AuthScreen(
              key: const ValueKey('auth'),
              members: _members,
              onSignIn: _signIn,
              onRegister: _registerAccount,
            )
          : _shell(context, _currentMember!),
    );
  }

  Widget _shell(BuildContext context, TeamMember me) {
    final titles = [
      ('Welcome back', 'Hi, ${me.name.split(' ').first}'),
      ('Workspace', 'Tasks'),
      ('People', 'Team'),
      ('Account', 'Profile'),
    ];
    final pages = <Widget>[
      DashboardScreen(
        tasks: _tasks,
        members: _members,
        onOpenTask: _openTask,
        onToggleTask: _toggleTask,
        onAddTask: () => _createOrEditTask(),
        onShowTasks: _showTasks,
      ),
      TasksScreen(
        tasks: _tasks,
        members: _members,
        filter: _taskFilter,
        onFilterChanged: (value) => setState(() => _taskFilter = value),
        onOpenTask: _openTask,
        onToggleTask: _toggleTask,
        onAddTask: () => _createOrEditTask(),
      ),
      TeamScreen(
        members: _members,
        tasks: _tasks,
        onSave: _saveMember,
        onDelete: _deleteMember,
      ),
      ProfileScreen(
        member: me,
        onSignOut: _signOut,
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
        notificationsEnabled: _notificationsEnabled,
        onNotificationsChanged: _setNotificationsEnabled,
        onOpenNotifications: _openNotifications,
      ),
    ];

    return Scaffold(
      key: const ValueKey('shell'),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                _TopBar(
                  eyebrow: titles[_tab].$1,
                  title: titles[_tab].$2,
                  member: me,
                  unread: _activities,
                  onBell: _openNotifications,
                  onAvatar: () => setState(() => _tab = 3),
                ),
                Expanded(
                  child: _FadeStack(index: _tab, children: pages),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        index: _tab,
        onChanged: (value) => setState(() => _tab = value),
        onAdd: () => _createOrEditTask(),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.eyebrow,
    required this.title,
    required this.member,
    required this.unread,
    required this.onBell,
    required this.onAvatar,
  });

  final String eyebrow;
  final String title;
  final TeamMember member;
  final ValueListenable<List<AppNotification>> unread;
  final VoidCallback onBell;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, .25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(title),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: context.scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        ValueListenableBuilder<List<AppNotification>>(
          valueListenable: unread,
          builder: (context, items, _) {
            final count = items.where((n) => !n.isRead).length;
            return Tooltip(
              message: 'Notifications',
              child: Pressable(
                borderRadius: 16,
                onTap: onBell,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: context.scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.scheme.outlineVariant),
                  ),
                  alignment: Alignment.center,
                  child: Badge(
                    isLabelVisible: count > 0,
                    label: Text(count > 9 ? '9+' : '$count'),
                    backgroundColor: context.colors.danger,
                    textColor: context.scheme.onError,
                    child: Icon(
                      count > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: context.scheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Profile',
          child: Pressable(
            borderRadius: 30,
            onTap: onAvatar,
            child: MemberAvatar(member: member, radius: 23),
          ),
        ),
      ],
    ),
  );
}

/// Keeps every tab alive and cross-fades when the selected tab changes.
class _FadeStack extends StatefulWidget {
  const _FadeStack({required this.index, required this.children});
  final int index;
  final List<Widget> children;

  @override
  State<_FadeStack> createState() => _FadeStackState();
}

class _FadeStackState extends State<_FadeStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: 1,
  );

  @override
  void didUpdateWidget(_FadeStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, .02),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: IndexedStack(index: widget.index, children: widget.children),
    ),
  );
}
