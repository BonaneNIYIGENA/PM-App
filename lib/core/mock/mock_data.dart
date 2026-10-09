import '../models/activity_model.dart';
import '../models/task_model.dart';

/// Fixed dashboard figures.
///
/// They come from the design and are deliberately independent of [mockTasks]:
/// the dashboard is a summary widget, not a derivation over the list below.
const int dashboardTotalTasks = 12;
const int dashboardOnTrack = 5;
const int dashboardAtRisk = 3;
const int dashboardOverdue = 2;
const int dashboardCompleted = 2;

/// Task counts per status drawn by the Task Overview donut and its legend.
const Map<TaskStatus, int> taskOverviewStatusCounts = <TaskStatus, int>{
  TaskStatus.onTrack: dashboardOnTrack,
  TaskStatus.atRisk: dashboardAtRisk,
  TaskStatus.overdue: dashboardOverdue,
};

/// The five tasks of the mock project.
final List<TaskModel> mockTasks = List<TaskModel>.unmodifiable(<TaskModel>[
  TaskModel(
    id: 'TSK-001',
    title: 'Design Login Screen',
    category: 'UI/UX Design',
    description: 'Create a clean and modern login screen for the application.',
    assignee: 'Sarah Lee',
    priority: 'High',
    dueDate: DateTime(2024, 12, 10),
    status: TaskStatus.onTrack,
  ),
  TaskModel(
    id: 'TSK-002',
    title: 'Implement Local Storage',
    category: 'Mobile Development',
    description: 'Persist tasks locally so the app keeps working offline.',
    assignee: 'Michael Chen',
    priority: 'High',
    dueDate: DateTime(2024, 12, 12),
    status: TaskStatus.atRisk,
  ),
  TaskModel(
    id: 'TSK-003',
    title: 'Create Task Model',
    category: 'Backend (Local)',
    description: 'Define the task entity and the repository that stores it.',
    assignee: 'Amina Yusuf',
    priority: 'Medium',
    dueDate: DateTime(2024, 12, 8),
    status: TaskStatus.overdue,
  ),
  TaskModel(
    id: 'TSK-004',
    title: 'Test Application',
    category: 'Quality Assurance',
    description: 'Walk through the main flows and log every defect found.',
    assignee: 'David Kim',
    priority: 'Medium',
    dueDate: DateTime(2024, 12, 15),
    status: TaskStatus.todo,
  ),
  TaskModel(
    id: 'TSK-005',
    title: 'Prepare Demo',
    category: 'Documentation',
    description: 'Write the demo script and the slides for the presentation.',
    assignee: 'Priya Nair',
    priority: 'Low',
    dueDate: DateTime(2024, 12, 18),
    status: TaskStatus.todo,
  ),
]);

/// The three entries of the dashboard activity feed.
const List<ActivityModel> mockActivities = <ActivityModel>[
  ActivityModel(
    userName: 'Sarah',
    taskTitle: 'UI Design',
    timeAgo: '2 hours ago',
  ),
  ActivityModel(
    userName: 'Michael',
    taskTitle: 'Local Storage',
    timeAgo: '5 hours ago',
  ),
  ActivityModel(
    userName: 'Amina',
    taskTitle: 'Task Model',
    timeAgo: 'Yesterday',
  ),
];
