import 'package:flutter/material.dart';

import '../components/components.dart';
import '../core/models/task_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Details of a single task, opened from the task list.
class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.task});

  final TaskModel task;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  /// Values offered by the editable status dropdown.
  static const List<String> _statusOptions = <String>[
    'To Do',
    'In Progress',
    'Completed',
  ];

  final TextEditingController _notesController = TextEditingController();
  String _status = 'In Progress';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// The copy the tracker shows for each status; the On Track message is the
  /// one used in the design reference.
  static String _slaMessageFor(TaskStatus status) => switch (status) {
    TaskStatus.onTrack => 'The task is progressing as expected.',
    TaskStatus.atRisk => 'This task is at risk of breaching its SLA.',
    TaskStatus.overdue => 'This task has breached its SLA.',
    TaskStatus.todo => 'Work on this task has not started yet.',
  };

  /// Only a high priority is highlighted; the design shows it in red.
  static Color _priorityColor(String priority) =>
      priority == 'High' ? AppColors.priorityHigh : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    final TaskModel task = widget.task;

    return Scaffold(
      appBar: AppHeader(
        variant: AppHeaderVariant.plain,
        title: 'Task Details',
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        trailing: IconButton(
          // TODO: open the task actions menu once it exists.
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
          tooltip: 'More options',
          visualDensity: VisualDensity.compact,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(task.title, style: AppTextStyles.h3)),
              const SizedBox(width: AppSpacing.md),
              StatusChip(status: task.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(task.category, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Text(task.description, style: AppTextStyles.subtitle),
          const SizedBox(height: AppSpacing.xl),
          DetailRow(
            icon: Icons.person_outline,
            label: 'Assigned to',
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                UserAvatar(
                  size: 24,
                  imageAsset: task.assigneeAvatar,
                  initials: UserAvatar.initialsFrom(task.assignee),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    task.assignee,
                    style: AppTextStyles.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Due Date',
            value: Text(task.formattedDueDate, style: AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            icon: Icons.flag_outlined,
            label: 'Priority',
            value: Text(
              task.priority,
              style: AppTextStyles.body.copyWith(
                color: _priorityColor(task.priority),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            icon: Icons.checklist,
            label: 'Status',
            value: AppDropdownField<String>(
              value: _status,
              items: <DropdownMenuItem<String>>[
                for (final String option in _statusOptions)
                  DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: AppTextStyles.body),
                  ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SlaStatusCard(
            status: task.status,
            message: _slaMessageFor(task.status),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('Notes'),
          const SizedBox(height: AppSpacing.md),
          AppNotesField(controller: _notesController),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Edit Task',
            // TODO: open the edit-task flow.
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
