class ProjectTask {
  const ProjectTask({
    this.id,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.priority,
    required this.deadline,
    required this.status,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String description;
  final int? assigneeId;
  final String priority;
  final DateTime deadline;
  final String status;
  final DateTime createdAt;

  bool get isCompleted => status == 'completed';

  ProjectTask copyWith({
    int? id,
    String? title,
    String? description,
    int? assigneeId,
    String? priority,
    DateTime? deadline,
    String? status,
  }) => ProjectTask(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    assigneeId: assigneeId ?? this.assigneeId,
    priority: priority ?? this.priority,
    deadline: deadline ?? this.deadline,
    status: status ?? this.status,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'assignee_id': assigneeId,
    'priority': priority,
    'deadline': deadline.toIso8601String(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };

  factory ProjectTask.fromMap(Map<String, Object?> map) => ProjectTask(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    assigneeId: map['assignee_id'] as int?,
    priority: map['priority'] as String? ?? 'Medium',
    deadline: DateTime.parse(map['deadline'] as String),
    status: map['status'] as String? ?? 'todo',
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

String taskStatusLabel(String status) => switch (status) {
  'inProgress' => 'In progress',
  'completed' => 'Completed',
  _ => 'To do',
};

String priorityLabel(String priority) => priority;
