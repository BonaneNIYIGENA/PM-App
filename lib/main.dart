import 'package:flutter/material.dart';

import 'services/notifications_service.dart';
import 'services/storage.dart';
import 'screens/home.dart';
import 'theme/apptheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationsService.initialize();
  } catch (_) {
    // The rest of the app remains usable if this device lacks notifications.
  }
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
    StorageService.instance
        .loadDarkMode()
        .then((enabled) {
          if (mounted) setState(() => _darkMode = enabled);
        })
        .catchError((_) {});
  }

  Future<void> _setDarkMode(bool enabled) async {
    setState(() => _darkMode = enabled);
    await StorageService.instance.saveDarkMode(enabled);
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
