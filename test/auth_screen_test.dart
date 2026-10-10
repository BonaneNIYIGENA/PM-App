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
    TeamMember? signedIn;
    await tester.pumpWidget(app((m) => signedIn = m));
    await tester.enterText(find.byType(TextFormField), 'AMY@mail.com');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(signedIn, member);
  });

  testWidgets('unknown email asks to create an account', (tester) async {
    await tester.pumpWidget(app((_) {}));
    await tester.enterText(find.byType(TextFormField), 'new@mail.com');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.textContaining('No account was found'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('blank email shows validation message', (tester) async {
    await tester.pumpWidget(app((_) {}));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
  });
}
