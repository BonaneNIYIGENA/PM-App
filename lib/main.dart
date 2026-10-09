import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'theme/apptheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProjectTrackerApp());
}

class ProjectTrackerApp extends StatelessWidget {
  const ProjectTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'taskMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
