import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pm_app/models/team_member.dart';
import 'package:pm_app/screens/auth_screen.dart';

void main() {
  const member = TeamMember(
    id: 1,
    name: 'Amy Lee',
    role: 'Project lead',
    email: 'amy@mail.com',
    initials: 'AL',
  );

  Widget app(ValueChanged<TeamMember> onSignIn) => MaterialApp(
    home: AuthScreen(
      members: const [member],
      onSignIn: onSignIn,
      onRegister: (name, email, role) async {},
    ),
  );

  testWidgets('registered email signs in', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    TeamMember? signedIn;
    await tester.pumpWidget(app((m) => signedIn = m));
    await tester.enterText(find.byType(TextFormField), 'AMY@mail.com');
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(seconds: 2));
    expect(signedIn, member);
  });

  testWidgets('unknown email asks to create an account', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app((_) {}));
    await tester.enterText(find.byType(TextFormField), 'new@mail.com');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('blank email shows validation message', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app((_) {}));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
  });
}
