class AppNotification {
  const AppNotification({
    this.id,
    required this.type,
    required this.title,
    required this.body,
    this.taskId,
    required this.createdAt,
    this.isRead = false,
  });

  final int? id;
  final String type;
  final String title;
  final String body;
  final int? taskId;
  final DateTime createdAt;
  final bool isRead;

  Map<String, Object?> toMap() => {
    'id': id,
    'type': type,
    'title': title,
    'body': body,
    'task_id': taskId,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead ? 1 : 0,
  };

  factory AppNotification.fromMap(Map<String, Object?> map) => AppNotification(
    id: map['id'] as int?,
    type: map['type'] as String? ?? 'info',
    title: map['title'] as String? ?? '',
    body: map['body'] as String? ?? '',
    taskId: map['task_id'] as int?,
    createdAt: DateTime.parse(map['created_at'] as String),
    isRead: (map['is_read'] as int? ?? 0) == 1,
  );
}
