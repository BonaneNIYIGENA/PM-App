import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'services/storage.dart';
import 'theme/apptheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProjectTrackerApp());
}

class ProjectTrackerApp extends StatefulWidget {
  const ProjectTrackerApp({super.key});

  @override
  State<ProjectTrackerApp> createState() => _ProjectTrackerAppState();
}

class _ProjectTrackerAppState extends State<ProjectTrackerApp> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    StorageService.instance.loadDarkMode().then((enabled) {
      if (mounted) setState(() => _darkMode = enabled);
    });
  }

  void _setDarkMode(bool enabled) {
    setState(() => _darkMode = enabled);
    StorageService.instance.saveDarkMode(enabled);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'taskMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(isDarkMode: _darkMode, onDarkModeChanged: _setDarkMode),
    );
  }
}
