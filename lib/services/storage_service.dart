import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz_result.dart';
import '../models/saved_study.dart';
import '../models/study_task.dart';

class StorageService {
  StorageService(this._prefs, {String? userId}) : _userId = userId;

  final SharedPreferences _prefs;
  final String? _userId;
  String _key(String base) => _userId == null ? base : '${base}_$_userId';

  static const _historyKey = 'study_ai_quiz_history_v1';
  static const _darkModeKey = 'study_ai_dark_mode_v1';
  static const _libraryKey = 'study_ai_library_v1';
  static const _tasksKey = 'study_ai_tasks_v1';
  static const _focusKey = 'study_ai_focus_v1';
  static const _dailyGoalKey = 'study_ai_daily_goal_v1';

  int loadDailyGoal() {
    final value = _prefs.getInt(_key(_dailyGoalKey)) ?? 10;
    return [5, 10, 15, 20].contains(value) ? value : 10;
  }

  Future<void> saveDailyGoal(int value) async {
    if (!await _prefs.setInt(_key(_dailyGoalKey), value)) {
      throw StateError('Não foi possível salvar a meta diária.');
    }
  }

  List<StudyTask> loadTasks() {
    final items = <StudyTask>[];
    for (final raw in _prefs.getStringList(_key(_tasksKey)) ?? <String>[]) {
      try {
        items.add(StudyTask.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {/* Preserve other valid tasks. */}
    }
    return items;
  }

  Future<void> saveTasks(List<StudyTask> tasks) async {
    if (!await _prefs.setStringList(_key(_tasksKey),
        tasks.map((task) => jsonEncode(task.toJson())).toList())) {
      throw StateError('Não foi possível salvar as tarefas.');
    }
  }

  Map<String, dynamic> loadFocus() {
    try {
      return jsonDecode(_prefs.getString(_key(_focusKey)) ?? '{}')
          as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveFocus(Map<String, dynamic> state) async {
    if (!await _prefs.setString(_key(_focusKey), jsonEncode(state))) {
      throw StateError('Não foi possível salvar o foco.');
    }
  }

  List<SavedStudy> loadLibrary() {
    final items = <SavedStudy>[];
    for (final raw in _prefs.getStringList(_key(_libraryKey)) ?? <String>[]) {
      try {
        items.add(SavedStudy.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        // Keep the readable entries if one saved item is damaged.
      }
    }
    return items;
  }

  Future<void> saveLibrary(List<SavedStudy> items) async {
    final saved = await _prefs.setStringList(_key(_libraryKey),
        items.map((item) => jsonEncode(item.toJson())).toList());
    if (!saved) throw StateError('Não foi possível salvar a biblioteca.');
  }

  List<QuizResult> loadQuizHistory() {
    final raw = _prefs.getStringList(_key(_historyKey)) ?? const <String>[];

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
    await _prefs.setStringList(_key(_historyKey), encoded);
  }

  bool loadDarkMode() => _prefs.getBool(_key(_darkModeKey)) ?? false;

  Future<void> saveDarkMode(bool enabled) async {
    await _prefs.setBool(_key(_darkModeKey), enabled);
  }

  Future<void> clearQuizHistory() async {
    await _prefs.remove(_key(_historyKey));
  }
}
