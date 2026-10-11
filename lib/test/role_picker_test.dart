import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/theme/apptheme.dart';
import 'package:pm_app/widgets/role_picker.dart';

void main() {
  testWidgets('add role saves a new role and selects it', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    final added = <String>[];
    var selected = 'Team member';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RolePicker(
              roles: const ['Project lead', 'Team member'],
              selected: selected,
              onSelected: (role) => setState(() => selected = role),
              onAddRole: (name) async => added.add(name),
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.code_rounded), findsNothing);
    await tester.tap(find.text('Add role'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Scrum master');
    await tester.tap(find.byTooltip('Save role'));
    await tester.pump();
    expect(added, ['Scrum master']);
    expect(selected, 'Scrum master');
    expect(find.text('Scrum master'), findsOneWidget);
  });

  testWidgets('add role rejects an existing role', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    final added = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: RolePicker(
            roles: const ['Project lead', 'Team member'],
            selected: 'Team member',
            onSelected: (_) {},
            onAddRole: (name) async => added.add(name),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Add role'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'project lead');
    await tester.tap(find.byTooltip('Save role'));
    await tester.pump();
    expect(find.text('This role already exists.'), findsOneWidget);
    expect(added, isEmpty);
  });
}
