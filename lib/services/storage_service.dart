import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz_result.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _historyKey = 'study_ai_quiz_history_v1';
  static const _darkModeKey = 'study_ai_dark_mode_v1';

  List<QuizResult> loadQuizHistory() {
    final raw = _prefs.getStringList(_historyKey) ?? const <String>[];

    return raw
        .map((item) {
          try {
            return QuizResult.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<QuizResult>()
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveQuizHistory(List<QuizResult> history) async {
    final encoded = history
        .map((item) => jsonEncode(item.toJson()))
        .toList(growable: false);
    await _prefs.setStringList(_historyKey, encoded);
  }

  bool loadDarkMode() => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> saveDarkMode(bool enabled) async {
    await _prefs.setBool(_darkModeKey, enabled);
  }

  Future<void> clearQuizHistory() async {
    await _prefs.remove(_historyKey);
  }
}
