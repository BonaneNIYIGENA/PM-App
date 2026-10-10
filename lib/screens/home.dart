import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/storage.dart';
import '../theme/apptheme.dart';
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
      return UserSelectionScreen(
        members: _members,
        onSelect: (member) => setState(() => _currentMember = member),
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

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({
    super.key,
    required this.members,
    required this.onSelect,
  });
  final List<TeamMember> members;
  final ValueChanged<TeamMember> onSelect;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome to taskMS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your team profile to continue.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  if (members.isEmpty)
                    const Text(
                      'No team members yet. Ask a teammate to add a profile.',
                    ),
                  ...members.map(
                    (member) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE8EDF8),
                            child: Text(
                              member.initials,
                              style: const TextStyle(
                                color: AppTheme.navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            member.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(member.role),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          onTap: () => onSelect(member),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
