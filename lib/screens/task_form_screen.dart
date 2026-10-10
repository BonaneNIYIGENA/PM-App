import 'package:flutter/material.dart';

import '../models/tasks.dart';
import '../models/team_member.dart';
import '../theme/apptheme.dart';
import '../widgets/common.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.members, this.task});
  final List<TeamMember> members;
  final ProjectTask? task;

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

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? 'Medium';
    _status = task?.status ?? 'todo';
    _deadline = task?.deadline ?? DateTime.now().add(const Duration(days: 3));
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

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Choose task deadline',
    );
    if (selected != null) {
      setState(
        () => _deadline = DateTime(
          selected.year,
          selected.month,
          selected.day,
          23,
          59,
        ),
      );
    }
  }

  void _submit() {
    if (widget.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a team member before assigning a task.'),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.task;
    Navigator.of(context).pop(
      ProjectTask(
        id: previous?.id,
        title: _title.text.trim(),
        description: _description.text.trim(),
        assigneeId: _assigneeId,
        priority: _priority,
        deadline: _deadline,
        status: _status,
        createdAt: previous?.createdAt ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 66,
        leading: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: AppBackButton(),
        ),
        title: Text(editing ? 'Edit task' : 'New task'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  FadeSlideIn(
                    child: Text(
                      editing ? 'Update the details below.' : 'Keep it clear so everyone knows what done looks like.',
                      style: TextStyle(
                        color: context.scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 1,
                    child: TextFormField(
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 80,
                      decoration: const InputDecoration(
                        labelText: 'Task title *',
                        hintText: 'e.g. Build onboarding screen',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a task title.';
                        }
                        if (value.trim().length < 3) {
                          return 'Use at least 3 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    index: 2,
                    child: TextFormField(
                      controller: _description,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Add helpful context for the assignee',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) => (value?.length ?? 0) > 500
                          ? 'Keep the description under 500 characters.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    index: 3,
                    child: DropdownButtonFormField<int>(
                      initialValue: _assigneeId,
                      borderRadius: BorderRadius.circular(16),
                      decoration: const InputDecoration(
                        labelText: 'Assign to *',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      items: widget.members
                          .where((member) => member.id != null)
                          .map(
                            (member) => DropdownMenuItem(
                              value: member.id!,
                              child: Text(member.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _assigneeId = value),
                      validator: (value) =>
                          value == null ? 'Choose a team member.' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(index: 4, child: _Label(text: 'Priority')),
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    index: 4,
                    child: Row(
                      children: [
                        for (final p in const ['Low', 'Medium', 'High'])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: p == 'High' ? 0 : 8,
                              ),
                              child: _Choice(
                                label: p,
                                color: priorityColor(context, p),
                                selected: _priority == p,
                                onTap: () => setState(() => _priority = p),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (editing) ...[
                    const SizedBox(height: 20),
                    const _Label(text: 'Progress status'),
                    const SizedBox(height: 8),
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
                              child: _Choice(
                                label: label,
                                color: context.scheme.primary,
                                selected: _status == key,
                                onTap: () => setState(() => _status = key),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 5,
                    child: AppCard(
                      onTap: _chooseDate,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      radius: 16,
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: context.scheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deadline',
                                  style: TextStyle(
                                    color: context.scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatDate(_deadline),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: context.scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(
                      editing ? Icons.check_rounded : Icons.add_rounded,
                    ),
                    label: Text(editing ? 'Save changes' : 'Create task'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.text.labelLarge?.copyWith(
      color: context.scheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
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
    borderRadius: 14,
    scale: .95,
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? context.soft(color, alpha: .18)
            : context.scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? color : context.scheme.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
          color: selected ? color : context.scheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}
