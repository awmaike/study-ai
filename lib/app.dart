import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

class StudyAIApp extends StatelessWidget {
  const StudyAIApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'StudyAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: theme.themeMode,
      home: home ?? const AppShell(),
    );
  }
}
