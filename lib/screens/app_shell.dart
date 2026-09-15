import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_action.dart';
import '../providers/study_provider.dart';
import 'home_screen.dart';
import 'performance_screen.dart';
import 'settings_screen.dart';
import 'study_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (_index == index) return;
    setState(() => _index = index);
    _pageController.jumpToPage(index);
  }

  void _openStudy([StudyAction? action]) {
    if (action != null) {
      context.read<StudyProvider>().selectAction(action);
    }
    _goTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpenStudy: _openStudy),
      const StudyScreen(),
      const PerformanceScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) {
                if (_index != value) setState(() => _index = value);
              },
              children: pages,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          height: 72,
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Estudar',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Progresso',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
