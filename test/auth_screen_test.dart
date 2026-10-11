import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/models/team_member.dart';
import 'package:pm_app/screens/auth_screen.dart';
import 'package:pm_app/theme/apptheme.dart';
import 'package:pm_app/widgets/member_form_sheet.dart';

// The create-account form is a sheet on top of the sign in page.
Finder _sheetFields() => find.descendant(
  of: find.byType(MemberFormSheet),
  matching: find.byType(TextFormField),
);

void main() {
  const member = TeamMember(
    id: 1,
    name: 'Amy Lee',
    role: 'Project lead',
    email: 'amy@mail.com',
    initials: 'AL',
  );

  Future<void> show(
    WidgetTester tester, {
    ValueChanged<TeamMember>? onSignIn,
    Future<void> Function(String, String, String)? onRegister,
    Future<void> Function(String)? onAddRole,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AuthScreen(
          roles: const ['Project lead', 'Team member'],
          onAddRole: onAddRole ?? (_) async {},
          members: const [member],
          onSignIn: onSignIn ?? (_) {},
          onRegister: onRegister ?? (name, email, role) async {},
        ),
      ),
    );
  }

  testWidgets('stored email signs in', (tester) async {
    TeamMember? signedIn;
    await show(tester, onSignIn: (m) => signedIn = m);
    await tester.enterText(find.byType(TextFormField), 'AMY@mail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(signedIn, member);
  });

  testWidgets('the email field always starts empty', (tester) async {
    await show(tester);
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, isEmpty);
  });

  testWidgets('unknown email only says it is not registered', (tester) async {
    await show(tester);
    await tester.enterText(find.byType(TextFormField), 'new@mail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('This email is not registered.'), findsOneWidget);
    expect(find.textContaining('New to taskMS?'), findsWidgets);
    // The create account form is not opened automatically.
    expect(find.text('Create your account'), findsNothing);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('clicking the link opens the create form with that email', (
    tester,
  ) async {
    await show(tester);
    await tester.enterText(find.byType(TextFormField), 'new@mail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tapOnText(
      find.textRange.ofSubstring('Click here to create an account.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
    expect(
      find.text(
        'This email is not registered yet. Create your account to continue.',
      ),
      findsOneWidget,
    );
    final emailInForm = tester.widget<TextFormField>(_sheetFields().last);
    expect(emailInForm.controller?.text, 'new@mail.com');
  });

  testWidgets('creating the account after an unknown email registers it', (
    tester,
  ) async {
    String? name, email;
    await show(
      tester,
      onRegister: (n, e, r) async {
        name = n;
        email = e;
      },
    );
    await tester.enterText(find.byType(TextFormField), 'new@mail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tapOnText(
      find.textRange.ofSubstring('Click here to create an account.'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(_sheetFields().first, 'New Person');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(name, 'New Person');
    expect(email, 'new@mail.com');
  });

  testWidgets('blank email shows validation message', (tester) async {
    await show(tester);
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter an email address.'), findsOneWidget);
  });

  testWidgets('create account asks for name email and role', (tester) async {
    String? name, email, role;
    await show(
      tester,
      onRegister: (n, e, r) async {
        name = n;
        email = e;
        role = r;
      },
    );
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
    await tester.enterText(_sheetFields().first, 'New Person');
    await tester.enterText(_sheetFields().last, 'New@Mail.com');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(name, 'New Person');
    expect(email, 'new@mail.com');
    expect(role, 'Team member');
  });

  testWidgets('create account rejects an email that already exists', (
    tester,
  ) async {
    var registered = false;
    await show(tester, onRegister: (n, e, r) async => registered = true);
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(_sheetFields().first, 'Amy Lee');
    await tester.enterText(_sheetFields().last, 'amy@mail.com');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
    expect(registered, isFalse);
  });

  testWidgets('create account rejects a name with digits', (tester) async {
    await show(tester);
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.enterText(_sheetFields().first, 'Amy123');
    await tester.enterText(_sheetFields().last, 'a@b.com');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Use letters'), findsOneWidget);
  });

  testWidgets('typed email is carried into the create account sheet', (
    tester,
  ) async {
    await show(tester);
    await tester.enterText(find.byType(TextFormField), 'new@mail.com');
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('new@mail.com'), findsWidgets);
    final emailInSheet = tester.widget<TextFormField>(_sheetFields().last);
    expect(emailInSheet.controller?.text, 'new@mail.com');
  });

  testWidgets('no storage footnote on the page', (tester) async {
    await show(tester);
    expect(find.textContaining('stored on this device'), findsNothing);
  });

  testWidgets('no tick or greeting appears while typing an email', (
    tester,
  ) async {
    await show(tester);
    await tester.enterText(find.byType(TextFormField), 'amy@mail.com');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.text('Welcome back,'), findsNothing);
    expect(find.text('Amy Lee'), findsNothing);
  });

  testWidgets('going back to sign in keeps the not registered message', (
    tester,
  ) async {
    await show(tester);
    await tester.enterText(find.byType(TextFormField), 'nobody@mail.com');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tapOnText(
      find.textRange.ofSubstring('Click here to create an account.'),
    );
    await tester.pumpAndSettle();
    // The sign in form was replaced by the create account form.
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('This email is not registered.'), findsOneWidget);
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);
  });

  testWidgets('only the create account form is on screen while creating', (
    tester,
  ) async {
    await show(tester);
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Welcome back'), findsNothing);
  });
}
