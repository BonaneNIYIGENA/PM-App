import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../theme/apptheme.dart';
import '../utils/validators.dart';
import '../widgets/common.dart';

// Create/edit task form, shown as a bottom sheet. Pops the saved ProjectTask.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({
    super.key,
    required this.members,
    this.task,
    this.onSubmit,
    this.onCancel,
  });
  final List<TeamMember> members;
  final ProjectTask? task;
  // When set, the form sits inside another sheet and reports the task here
  // instead of closing itself.
  final ValueChanged<ProjectTask>? onSubmit;
  final VoidCallback? onCancel;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _priority;
  late String _status;
  late DateTime _deadline;
  int? _assigneeId;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? 'Medium';
    _status = task?.status ?? 'todo';
    _deadline =
        task?.deadline ??
        _endOfDay(DateTime.now().add(const Duration(days: 3)));
    _assigneeId =
        task?.assigneeId ??
        (widget.members.isEmpty ? null : widget.members.first.id);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59);

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: widget.task == null ? DateTime.now() : DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Choose task deadline',
    );
    if (selected != null) {
      setState(() {
        _deadline = _endOfDay(selected);
        _formError = null;
      });
    }
  }

  void _submit() {
    if (widget.members.isEmpty) {
      setState(() => _formError = 'Add a team member before assigning a task.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.task;
    final deadlineError = previous == null
        ? Validators.deadline(_deadline)
        : null;
    if (deadlineError != null) {
      setState(() => _formError = deadlineError);
      return;
    }
    final saved = ProjectTask(
      id: previous?.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      assigneeId: _assigneeId,
      priority: _priority,
      deadline: _deadline,
      status: _status,
      createdAt: previous?.createdAt ?? DateTime.now(),
    );
    final onSubmit = widget.onSubmit;
    if (onSubmit != null) {
      onSubmit(saved);
    } else {
      Navigator.of(context).pop(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    final form = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing ? 'Edit task' : 'Add new task',
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  editing
                      ? 'Update the details below.'
                      : 'Keep it clear so everyone knows what done looks like.',
                  style: TextStyle(color: context.scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormLabel('Task title', required: true),
                  TextFormField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Build onboarding screen',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                    validator: Validators.taskTitle,
                  ),
                  const SizedBox(height: 10),
                  const FormLabel('Description'),
                  TextFormField(
                    controller: _description,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Add helpful context for the assignee',
                    ),
                    validator: Validators.description,
                  ),
                  const SizedBox(height: 18),
                  const FormLabel('Assign to', required: true),
                  DropdownButtonFormField<int>(
                    initialValue: _assigneeId,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    decoration: const InputDecoration(
                      hintText: 'Choose a team member',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    items: widget.members
                        .where((member) => member.id != null)
                        .map(
                          (member) => DropdownMenuItem(
                            value: member.id!,
                            child: Text('${member.name} · ${member.role}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _assigneeId = value),
                    validator: (value) =>
                        Validators.required(value, 'Choose a team member.'),
                  ),
                  const SizedBox(height: 18),
                  const FormLabel('Priority'),
                  Row(
                    children: [
                      for (final p in const ['Low', 'Medium', 'High'])
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: p == 'High' ? 0 : 8,
                            ),
                            child: _Pill(
                              label: p,
                              color: priorityColor(context, p),
                              selected: _priority == p,
                              onTap: () => setState(() => _priority = p),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const FormLabel('Deadline', required: true),
                  AppCard(
                    onTap: _chooseDate,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    radius: 14,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: context.scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            formatDate(_deadline),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  if (editing) ...[
                    const SizedBox(height: 18),
                    const FormLabel('Progress status'),
                    Row(
                      children: [
                        for (final (key, label) in const [
                          ('todo', 'To do'),
                          ('inProgress', 'In progress'),
                          ('completed', 'Completed'),
                        ])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: key == 'completed' ? 0 : 8,
                              ),
                              child: _Pill(
                                label: label,
                                color: context.colors.info,
                                selected: _status == key,
                                onTap: () => setState(() => _status = key),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (_formError != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: context.colors.danger,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formError!,
                            style: TextStyle(color: context.colors.danger),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: context.isDark
                        ? context.colors.violet
                        : AppTheme.ink,
                    foregroundColor: context.isDark
                        ? Colors.black
                        : Colors.white,
                  ),
                  icon: Icon(editing ? Icons.check_rounded : Icons.add_rounded),
                  label: Text(editing ? 'Save changes' : 'Create task'),
                ),
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (widget.onSubmit != null) return form;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .92,
        ),
        child: form,
      ),
    );
  }
}

// Rounded outlined choice, filled with its color when selected.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    borderRadius: 24,
    scale: .95,
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? context.soft(color, alpha: .2) : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: .45),
          width: selected ? 1.8 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          color: color,
        ),
      ),
    ),
  );
}
