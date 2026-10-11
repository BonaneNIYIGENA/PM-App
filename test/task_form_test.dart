import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/models/team_member.dart';
import 'package:pm_app/screens/task_form_screen.dart';
import 'package:pm_app/theme/apptheme.dart';

void main() {
  const member = TeamMember(
    id: 1,
    name: 'Amy Lee',
    role: 'Project lead',
    email: 'amy@mail.com',
    initials: 'AL',
  );

  Future<void> show(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: TaskFormScreen(members: [member])),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('empty title is rejected', (tester) async {
    await show(tester);
    await tester.tap(find.text('Create task'));
    await tester.pump();
    expect(find.text('Enter a task title.'), findsOneWidget);
  });

  testWidgets('too short title is rejected', (tester) async {
    await show(tester);
    await tester.enterText(find.byType(TextFormField).first, 'ab');
    await tester.tap(find.text('Create task'));
    await tester.pump();
    expect(find.text('Use at least 3 characters.'), findsOneWidget);
  });
}
