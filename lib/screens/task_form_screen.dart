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
