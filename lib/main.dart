import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  const endpoint = String.fromEnvironment('AI_ENDPOINT');
  const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (endpoint.isNotEmpty && publishableKey.isNotEmpty) {
    await Supabase.initialize(
      url: Uri.parse(endpoint).origin,
      publishableKey: publishableKey,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storage),
        ),
      ],
      child: StudyAIApp(
        home: endpoint.isNotEmpty && publishableKey.isNotEmpty
            ? AuthGate(preferences: prefs)
            : const Scaffold(
                body: Center(
                  child: Text(
                      'Inicie pelo run_study_ai.bat para acessar sua conta.'),
                ),
              ),
      ),
    ),
  );
}
