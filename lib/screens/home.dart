import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/storage.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';
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
  List<ProjectTask> _tasks = [];
  List<TeamMember> _members = [];
  TeamMember? _currentMember;
  int _tab = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _storage.loadTasks(),
        _storage.loadMembers(),
      ]);
      if (!mounted) return;
      setState(() {
        _tasks = results[0] as List<ProjectTask>;
        _members = results[1] as List<TeamMember>;
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
        TeamMember? refreshedMember;
        for (final member in members) {
          if (member.id == _currentMember!.id) {
            refreshedMember = member;
            break;
          }
        }
        _currentMember = refreshedMember;
      }
    });
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
      return saved.copyWith(id: saved.id ?? id);
    } catch (_) {
      _showStorageError('save the task');
      return null;
    }
  }

  Future<void> _openTask(ProjectTask task) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(
          task: task,
          members: _members,
          onEdit: () => _createOrEditTask(task),
          onUpdate: (updated) async {
            try {
              await _storage.saveTask(updated);
              await _refresh();
            } catch (_) {
              _showStorageError('update the task');
              rethrow;
            }
          },
          onDelete: () async {
            try {
              await _storage.deleteTask(task.id!);
              await _refresh();
            } catch (_) {
              _showStorageError('delete the task');
              rethrow;
            }
          },
        ),
      ),
    );
    await _refresh();
  }

  Future<void> _registerAccount(String name, String email, String role) async {
    final initials = name
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
      final created = _members.firstWhere((m) => m.email == email);
      if (mounted) setState(() => _currentMember = created);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create your account.')),
      );
    }
  }

  Future<void> _saveMember(TeamMember member) async {
    try {
      await _storage.saveMember(member);
      await _refresh();
    } catch (_) {
      _showStorageError('save the team member');
    }
  }

  Future<void> _deleteMember(TeamMember member) async {
    if (member.id == null) return;
    if (_members.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keep at least one team member in the workspace.'),
        ),
      );
      return;
    }
    try {
      await _storage.deleteMember(member.id!);
      if (_currentMember?.id == member.id) _currentMember = null;
      await _refresh();
    } catch (_) {
      _showStorageError('remove the team member');
    }
  }

  void _showStorageError(String action) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not $action. Please try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_rounded, size: 44),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                    });
                    _loadData();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_currentMember == null) {
      return AuthScreen(
        members: _members,
        onSignIn: (member) => setState(() => _currentMember = member),
        onRegister: _registerAccount,
      );
    }

    final pages = <Widget>[
      DashboardScreen(
        tasks: _tasks,
        members: _members,
        currentMember: _currentMember!,
        onOpenTask: _openTask,
        onAddTask: () => _createOrEditTask(),
        onShowTasks: () => setState(() => _tab = 1),
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      ),
      TasksScreen(
        tasks: _tasks,
        members: _members,
        onOpenTask: _openTask,
        onAddTask: () => _createOrEditTask(),
      ),
      TeamScreen(
        members: _members,
        tasks: _tasks,
        onSave: _saveMember,
        onDelete: _deleteMember,
      ),
      ProfileScreen(
        member: _currentMember!,
        onSignOut: () => setState(() => _currentMember = null),
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tab, children: pages),
      ),
      floatingActionButton: _tab == 1
          ? FloatingActionButton.extended(
              onPressed: () => _createOrEditTask(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New task'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() => _tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
