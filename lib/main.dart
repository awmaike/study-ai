import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/study_provider.dart';
import 'providers/theme_provider.dart';
import 'services/ai_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storage),
        ),
        ChangeNotifierProvider(
          create: (_) => StudyProvider(
            aiService: AIService(),
            storageService: storage,
          ),
        ),
      ],
      child: const StudyAIApp(),
    ),
  );
}
