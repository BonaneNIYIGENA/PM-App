/// One entry of the "Recent Activity" list on the dashboard.
class ActivityModel {
  const ActivityModel({
    required this.userName,
    required this.taskTitle,
    required this.timeAgo,
    this.avatar,
  });

  final String userName;

  /// Name of the task the user worked on; rendered in bold inside the tile.
  final String taskTitle;

  /// Pre-formatted relative time, for example `2 hours ago`.
  final String timeAgo;

  /// Avatar image of [userName]; when null the avatar falls back to initials.
  final String? avatar;
}
