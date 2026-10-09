import 'package:flutter/material.dart';

import '../components/components.dart';
import '../core/theme/app_text_styles.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';

/// App shell: keeps the four tabs alive in an [IndexedStack] and switches
/// between them with the bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const <Widget>[
          DashboardScreen(),
          TasksScreen(),
          _ComingSoonPlaceholder(),
          _ComingSoonPlaceholder(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// Placeholder for the Team and Profile tabs, which are out of scope.
class _ComingSoonPlaceholder extends StatelessWidget {
  const _ComingSoonPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Coming soon', style: AppTextStyles.body));
  }
}
