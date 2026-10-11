import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/models/team_member.dart';
import 'package:pm_app/utils/validators.dart';

void main() {
  const amy = TeamMember(
    id: 1,
    name: 'Amy Lee',
    role: 'Project lead',
    email: 'amy@mail.com',
    initials: 'AL',
  );

  test('email needs a value and a valid format', () {
    expect(Validators.email(''), isNotNull);
    expect(Validators.email('amy@'), isNotNull);
    expect(Validators.email('amy mail@x.com'), isNotNull);
    expect(Validators.email('amy@mail.com'), isNull);
  });

  test('unique email rejects another member but not the same one', () {
    expect(Validators.uniqueEmail('AMY@mail.com', [amy]), isNotNull);
    expect(Validators.uniqueEmail('AMY@mail.com', [amy], exceptId: 1), isNull);
    expect(Validators.uniqueEmail('new@mail.com', [amy]), isNull);
  });

  test('person name allows letters and rejects digits and symbols', () {
    expect(Validators.personName(''), isNotNull);
    expect(Validators.personName('A'), isNotNull);
    expect(Validators.personName('Amy123'), isNotNull);
    expect(Validators.personName("Amy O'Neil-Lee"), isNull);
    expect(Validators.personName('Élodie Mukamana'), isNull);
  });

  test('task title length and content', () {
    expect(Validators.taskTitle('  '), isNotNull);
    expect(Validators.taskTitle('ab'), isNotNull);
    expect(Validators.taskTitle('!!!'), isNotNull);
    expect(Validators.taskTitle('a' * 81), isNotNull);
    expect(Validators.taskTitle('Fix login'), isNull);
  });

  test('description is optional but limited', () {
    expect(Validators.description(null), isNull);
    expect(Validators.description('a' * 501), isNotNull);
  });

  test('deadline cannot be in the past', () {
    final now = DateTime(2026, 10, 11, 15);
    expect(Validators.deadline(DateTime(2026, 10, 10), now: now), isNotNull);
    expect(
      Validators.deadline(DateTime(2026, 10, 11, 23, 59), now: now),
      isNull,
    );
    expect(Validators.deadline(null), isNotNull);
  });

  test('new role must be new and a sensible length', () {
    const roles = ['Project lead', 'Team member'];
    expect(Validators.roleName('', roles), isNotNull);
    expect(Validators.roleName('A', roles), isNotNull);
    expect(Validators.roleName('x' * 31, roles), isNotNull);
    expect(Validators.roleName('PROJECT LEAD', roles), isNotNull);
    expect(Validators.roleName('Scrum master', roles), isNull);
  });
}
