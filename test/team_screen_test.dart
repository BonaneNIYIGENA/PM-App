import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/models/tasks.dart';
import 'package:pm_app/models/team_member.dart';
import 'package:pm_app/screens/team_screen.dart';
import 'package:pm_app/theme/apptheme.dart';

ProjectTask _task(int assignee, Duration fromNow, {String status = 'todo'}) {
  final now = DateTime.now();
  return ProjectTask(
    title: 'Task',
    description: '',
    assigneeId: assignee,
    priority: 'Medium',
    deadline: now.add(fromNow),
    status: status,
    createdAt: now,
  );
}

void main() {
  const amy = TeamMember(
    id: 1,
    name: 'Amy Lee',
    role: 'Project lead',
    email: 'amy@mail.com',
    initials: 'AL',
  );
  const bob = TeamMember(
    id: 2,
    name: 'Bob Ray',
    role: 'QA engineer',
    email: 'bob@mail.com',
    initials: 'BR',
  );

  testWidgets('bar legend counts each status and hides empty ones', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TeamScreen(
            roles: const ['Project lead', 'Team member'],
            onAddRole: (_) async {},
            members: const [amy, bob],
            tasks: [
              _task(1, const Duration(days: 5), status: 'completed'),
              _task(1, const Duration(days: 5)),
              _task(1, const Duration(hours: 5)),
              _task(1, const Duration(days: -2)),
            ],
            onSave: (_) async {},
            onDelete: (_) async {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1 completed'), findsOneWidget);
    expect(find.text('1 on track'), findsOneWidget);
    expect(find.text('1 at risk'), findsOneWidget);
    expect(find.text('1 overdue'), findsOneWidget);
    expect(find.textContaining('open'), findsNothing);
  });

  testWidgets('tapping a member card opens its details', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TeamScreen(
            roles: const ['Project lead', 'Team member'],
            onAddRole: (_) async {},
            members: const [amy],
            tasks: const [],
            onSave: (_) async {},
            onDelete: (_) async {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Assigned tasks'), findsNothing);
    await tester.tap(find.text('Amy Lee'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Assigned tasks'), findsOneWidget);
    expect(find.text('amy@mail.com'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });

  testWidgets('add member opens a sheet that validates the form', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    TeamMember? saved;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TeamScreen(
            roles: const ['Project lead', 'Team member'],
            onAddRole: (_) async {},
            members: const [amy],
            tasks: const [],
            onSave: (m) async => saved = m,
            onDelete: (_) async {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add team member'), findsOneWidget);
    await tester.tap(find.text('Add member'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(saved, isNull);
    await tester.enterText(find.byType(TextFormField).first, 'Eli Kura');
    await tester.enterText(find.byType(TextFormField).last, 'eli@mail.com');
    await tester.tap(find.text('Add member'));
    await tester.pumpAndSettle();
    expect(saved?.name, 'Eli Kura');
    expect(saved?.initials, 'EK');
  });

  testWidgets('removing a member asks first and then calls delete', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    TeamMember? removed;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TeamScreen(
            members: const [amy, bob],
            roles: const ['Project lead', 'Team member'],
            onAddRole: (_) async {},
            tasks: const [],
            onSave: (_) async {},
            onDelete: (m) async => removed = m,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Bob Ray'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Bob Ray?'), findsOneWidget);
    expect(
      find.textContaining('will need to create a new account'),
      findsOneWidget,
    );
    expect(removed, isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(removed, isNull);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(removed?.id, 2);
  });
}
