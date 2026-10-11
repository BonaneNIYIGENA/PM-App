import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../services/sla_service.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';
import '../widgets/task_card.dart';

const taskFilters = [
  'All',
  'To do',
  'In progress',
  'Completed',
  'At risk',
  'Overdue',
];

class TasksScreen extends StatefulWidget {
  const TasksScreen({
    super.key,
    required this.tasks,
    required this.members,
    required this.filter,
    required this.onFilterChanged,
    required this.onOpenTask,
    required this.onToggleTask,
    required this.onAddTask,
  });
  final List<ProjectTask> tasks;
  final List<TeamMember> members;
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<ProjectTask> onOpenTask;
  final ValueChanged<ProjectTask> onToggleTask;
  final VoidCallback onAddTask;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.tasks.where((task) {
      final member = memberFor(widget.members, task.assigneeId);
      final matchesSearch =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          (member?.name.toLowerCase().contains(query) ?? false);
      final sla = SlaService.calculate(task);
      final matchesFilter = switch (widget.filter) {
        'To do' => task.status == 'todo',
        'In progress' => task.status == 'inProgress',
        'Completed' => sla == SlaStatus.completed,
        'At risk' => sla == SlaStatus.atRisk,
        'Overdue' => sla == SlaStatus.overdue,
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Search tasks or people',
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: taskFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) => _FilterChip(
              label: taskFilters[index],
              selected: widget.filter == taskFilters[index],
              onTap: () => widget.onFilterChanged(taskFilters[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 20, 4),
          child: Text(
            '${filtered.length} ${filtered.length == 1 ? 'task' : 'tasks'}',
            style: context.text.labelLarge?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: filtered.isEmpty
                ? EmptyState(
                    key: const ValueKey('empty'),
                    icon: widget.tasks.isEmpty
                        ? Icons.inbox_outlined
                        : Icons.search_off_rounded,
                    title: widget.tasks.isEmpty
                        ? 'No tasks yet'
                        : 'No matching tasks',
                    message: widget.tasks.isEmpty
                        ? 'Create a task to get your project moving.'
                        : 'Try changing your search or filter.',
                    actionLabel: widget.tasks.isEmpty ? 'Create task' : null,
                    onAction: widget.onAddTask,
                  )
                : ListView.separated(
                    key: ValueKey(widget.filter),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 130),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return FadeSlideIn(
                        key: ValueKey('${task.id}-${widget.filter}'),
                        index: index,
                        child: TaskCard(
                          task: task,
                          member: memberFor(widget.members, task.assigneeId),
                          onTap: () => widget.onOpenTask(task),
                          onToggle: () => widget.onToggleTask(task),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Pressable(
      borderRadius: 20,
      scale: .94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? scheme.onSurface : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? scheme.surface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
