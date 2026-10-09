import 'package:flutter/material.dart';

import '../components/components.dart';
import '../core/mock/mock_data.dart';
import '../core/models/task_model.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'task_details_screen.dart';

/// Tasks tab: search, status filters and the list of tasks.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  /// Status behind each filter pill; `null` is the "All" pill.
  static const List<TaskStatus?> _filterStatuses = <TaskStatus?>[
    null,
    TaskStatus.onTrack,
    TaskStatus.atRisk,
    TaskStatus.overdue,
  ];

  int _selectedFilter = 0;
  String _query = '';

  /// Derived from [_filterStatuses] so the pills can never drift from the
  /// labels used by [StatusChip].
  List<String> get _filterLabels => <String>[
    'All',
    for (final TaskStatus status in _filterStatuses.whereType<TaskStatus>())
      StatusChip.labelFor(status),
  ];

  List<TaskModel> get _visibleTasks {
    final String query = _query.trim().toLowerCase();
    final TaskStatus? status = _filterStatuses[_selectedFilter];

    return mockTasks
        .where(
          (TaskModel task) =>
              (status == null || task.status == status) &&
              (query.isEmpty || task.title.toLowerCase().contains(query)),
        )
        .toList();
  }

  void _openDetails(TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TaskDetailsScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<TaskModel> tasks = _visibleTasks;

    return Scaffold(
      appBar: AppHeader(
        title: 'Tasks',
        leading: IconButton(
          // TODO: open the navigation drawer once it exists.
          onPressed: () {},
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
        ),
        trailing: const UserAvatar.onPrimary(initials: 'JD'),
      ),
      floatingActionButton: AppFab(
        // TODO: open the create-task flow.
        onPressed: () {},
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              children: <Widget>[
                AppSearchBar(
                  onChanged: (String value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.md),
                FilterChipBar(
                  labels: _filterLabels,
                  selectedIndex: _selectedFilter,
                  onSelected: (int index) =>
                      setState(() => _selectedFilter = index),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: tasks.isEmpty
                ? const _EmptyTasksState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSizes.fabClearance,
                    ),
                    itemCount: tasks.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (BuildContext context, int index) {
                      final TaskModel task = tasks[index];
                      return TaskListCard(
                        task: task,
                        onTap: () => _openDetails(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the search text and the selected filter match no task.
class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const UndrawIllustration(
            'assets/illustrations/no_tasks.svg',
            height: 160,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('No tasks found', style: AppTextStyles.title),
        ],
      ),
    );
  }
}
