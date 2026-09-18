import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/study_provider.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import 'app_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final GoTrueClient _auth = Supabase.instance.client.auth;
  late String? _userId = _auth.currentSession?.user.id;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _auth.onAuthStateChange.listen((state) {
      final nextId = state.session?.user.id;
      if (mounted && nextId != _userId) {
        setState(() => _userId = nextId);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;
    if (userId == null) return const LoginScreen();

    return ChangeNotifierProvider<StudyProvider>(
      key: ValueKey(userId),
      create: (_) => StudyProvider(
        aiService: AIService(
          accessToken: () =>
              Supabase.instance.client.auth.currentSession?.accessToken,
        ),
        storageService: StorageService(widget.preferences, userId: userId),
      ),
      child: AppShell(
        accountEmail: _auth.currentUser?.email,
        onSignOut: () => _auth.signOut(),
      ),
    );
  }
}
