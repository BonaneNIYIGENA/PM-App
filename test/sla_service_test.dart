import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/models/tasks.dart';
import 'package:pm_app/services/sla_service.dart';

ProjectTask _task(Duration fromNow, {String status = 'todo'}) {
  final now = DateTime(2026, 1, 1);
  return ProjectTask(
    title: 't',
    description: '',
    assigneeId: null,
    priority: 'Medium',
    deadline: now.add(fromNow),
    status: status,
    createdAt: now,
  );
}

void main() {
  final now = DateTime(2026, 1, 1);

  test('completed wins over a past deadline', () {
    final task = _task(const Duration(days: -3), status: 'completed');
    expect(SlaService.calculate(task, now: now), SlaStatus.completed);
  });

  test('past deadline is overdue', () {
    final task = _task(const Duration(hours: -1));
    expect(SlaService.calculate(task, now: now), SlaStatus.overdue);
  });

  test('deadline within 48 hours is at risk', () {
    final task = _task(const Duration(hours: 48));
    expect(SlaService.calculate(task, now: now), SlaStatus.atRisk);
  });

  test('deadline after 48 hours is on track', () {
    final task = _task(const Duration(hours: 49));
    expect(SlaService.calculate(task, now: now), SlaStatus.onTrack);
  });
}
