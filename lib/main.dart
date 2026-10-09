import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PmApp());
}

/// Root of the Project & SLA Task Tracker app.
class PmApp extends StatelessWidget {
  const PmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project & SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
