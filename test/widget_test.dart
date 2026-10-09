import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pm_app/components/components.dart';
import 'package:pm_app/core/theme/app_theme.dart';
import 'package:pm_app/main.dart';
import 'package:pm_app/screens/tasks_screen.dart';

/// Pins the surface to the 390x844 phone the design targets so that no control
/// ends up outside of the viewport.
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Finder for a single pill of the [FilterChipBar], ignoring the identically
/// named status chips of the task cards.
Finder _filterPill(String label) {
  return find.descendant(
    of: find.byType(FilterChipBar),
    matching: find.text(label),
  );
}

void main() {
  setUpAll(() {
    // The tests have no network access; use the fallback font instead of
    // letting google_fonts try to download Inter.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('login screen rejects empty credentials', (
    WidgetTester tester,
  ) async {
    _usePhoneViewport(tester);

    await tester.pumpWidget(const PmApp());
    await tester.pumpAndSettle();

    expect(find.text('Project & SLA Task Tracker'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(2));
    expect(find.text('Good morning, John'), findsNothing);
  });

  testWidgets('signing in opens the dashboard', (WidgetTester tester) async {
    _usePhoneViewport(tester);

    await tester.pumpWidget(const PmApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'john@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.pump();

    await tester.tap(find.text('Sign In'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Good morning, John'), findsOneWidget);
    expect(find.text('Total Tasks'), findsOneWidget);
    expect(find.text('Task Overview'), findsOneWidget);
    expect(find.text('Sarah updated UI Design'), findsOneWidget);
  });

  testWidgets('search narrows the task list and reports an empty result', (
    WidgetTester tester,
  ) async {
    _usePhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const TasksScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Design Login Screen'), findsOneWidget);
    expect(find.text('Prepare Demo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'local');
    await tester.pumpAndSettle();

    expect(find.text('Implement Local Storage'), findsOneWidget);
    expect(find.text('Design Login Screen'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'nothing matches');
    await tester.pumpAndSettle();

    expect(find.text('No tasks found'), findsOneWidget);
  });

  testWidgets('a status filter narrows the list and a card opens the details', (
    WidgetTester tester,
  ) async {
    _usePhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const TasksScreen()),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(_filterPill('Overdue'));
    await tester.tap(_filterPill('Overdue'));
    await tester.pumpAndSettle();

    expect(find.text('Create Task Model'), findsOneWidget);
    expect(find.text('Design Login Screen'), findsNothing);

    await tester.tap(find.text('Create Task Model'));
    await tester.pumpAndSettle();

    expect(find.text('Task Details'), findsOneWidget);
    expect(find.text('SLA Status'), findsOneWidget);
    expect(find.text('The task has breached its SLA.'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Task Details'), findsNothing);
    expect(find.text('Tasks'), findsOneWidget);
  });
}
