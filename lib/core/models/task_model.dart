/// Lifecycle state of a task, one value per status chip in the design.
enum TaskStatus { onTrack, atRisk, overdue, todo }

/// Formats [date] as `d MMM yyyy`, for example `10 Dec 2024`.
///
/// The app does not depend on `intl`, so the month names are listed here.
String formatTaskDate(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// A task as shown in the task list, the dashboard overview and the details
/// screen.
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.assignee,
    required this.priority,
    required this.dueDate,
    required this.status,
    this.assigneeAvatar,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String assignee;

  /// Avatar image of [assignee]; when null the avatar falls back to initials.
  final String? assigneeAvatar;

  /// One of `High`, `Medium` or `Low`.
  final String priority;
  final DateTime dueDate;
  final TaskStatus status;

  /// [dueDate] rendered the way the task cards and details rows show it.
  String get formattedDueDate => formatTaskDate(dueDate);
}
