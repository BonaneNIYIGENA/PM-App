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
