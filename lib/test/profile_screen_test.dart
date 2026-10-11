import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/models/tasks.dart';
import 'package:pm_app/models/team_member.dart';
import 'package:pm_app/screens/profile_screen.dart';
import 'package:pm_app/theme/apptheme.dart';

ProjectTask _task(int assignee, {String status = 'todo', int days = 5}) =>
    ProjectTask(
      title: 'Task',
      description: '',
      assigneeId: assignee,
      priority: 'Medium',
      deadline: DateTime.now().add(Duration(days: days)),
      status: status,
      createdAt: DateTime.now(),
    );

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

  Future<void> show(
    WidgetTester tester, {
    TeamMember member = amy,
    List<ProjectTask> tasks = const [],
    Future<void> Function(TeamMember)? onUpdate,
    VoidCallback? onSignOut,
    bool isDarkMode = false,
    ValueChanged<bool>? onDarkModeChanged,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ProfileScreen(
            roles: const ['Project lead', 'Team member'],
            onAddRole: (_) async {},
            member: member,
            members: const [amy, bob],
            tasks: tasks,
            onUpdate: onUpdate ?? (_) async {},
            onSignOut: onSignOut ?? () {},
            isDarkMode: isDarkMode,
            onDarkModeChanged: onDarkModeChanged ?? (_) {},
            onOpenNotifications: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('stats count only the signed in member tasks', (tester) async {
    final tasks = [
      _task(1),
      _task(1, status: 'completed'),
      _task(1, days: -2),
      _task(2),
      _task(2),
      _task(2),
    ];
    await show(tester, tasks: tasks);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Assigned'), findsOneWidget);
    // Amy has 3 tasks, 1 completed, 1 overdue.
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets('no deadline reminders row', (tester) async {
    await show(tester);
    expect(find.text('Deadline reminders'), findsNothing);
    expect(find.text('Edit profile'), findsOneWidget);
  });

  testWidgets('edit profile saves a valid name and email', (tester) async {
    TeamMember? saved;
    await show(tester, onUpdate: (m) async => saved = m);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Amy Grace Lee');
    await tester.enterText(find.byType(TextFormField).last, 'New@Mail.com');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(saved?.name, 'Amy Grace Lee');
    expect(saved?.email, 'new@mail.com');
    expect(saved?.initials, 'AG');
    expect(saved?.id, 1);
  });

  testWidgets('edit profile rejects another member email', (tester) async {
    TeamMember? saved;
    await show(tester, onUpdate: (m) async => saved = m);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'bob@mail.com');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(
      find.text('Another member already uses this email.'),
      findsOneWidget,
    );
    expect(saved, isNull);
  });

  testWidgets('sign out signs out straight away without asking', (
    tester,
  ) async {
    var signedOut = 0;
    await show(tester, onSignOut: () => signedOut++);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(signedOut, 1);
    expect(find.text('Sign out?'), findsNothing);
  });

  testWidgets('app theme is a light/dark toggle, not an on/off switch', (
    tester,
  ) async {
    bool? chosen;
    await show(tester, onDarkModeChanged: (dark) => chosen = dark);
    expect(find.text('App theme'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(chosen, isTrue);
  });

  testWidgets('sign out is a single centred button with no extra text', (
    tester,
  ) async {
    await show(tester);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.textContaining('End your session'), findsNothing);
  });
}
