import '../models/tasks.dart';

enum SlaStatus { onTrack, atRisk, overdue, completed }

class SlaService {
  static SlaStatus calculate(ProjectTask task, {DateTime? now}) {
    if (task.isCompleted) return SlaStatus.completed;
    final current = now ?? DateTime.now();
    if (task.deadline.isBefore(current)) return SlaStatus.overdue;
    if (task.deadline.difference(current) <= const Duration(hours: 48)) {
      return SlaStatus.atRisk;
    }
    return SlaStatus.onTrack;
  }

  static String label(SlaStatus status) => switch (status) {
    SlaStatus.onTrack => 'On track',
    SlaStatus.atRisk => 'At risk',
    SlaStatus.overdue => 'Overdue',
    SlaStatus.completed => 'Completed',
  };
}
