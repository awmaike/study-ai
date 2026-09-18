import 'package:flutter/foundation.dart';

import '../models/flashcard.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/study_action.dart';
import '../models/saved_study.dart';
import '../models/study_task.dart';
import '../models/study_image.dart';
import 'focus_timer.dart';
import '../services/quiz_shuffle.dart';
import '../services/ai_service.dart';
import '../services/demo_ai_service.dart';
import '../services/storage_service.dart';

class StudyProvider extends ChangeNotifier {
  StudyProvider({
    required AIService aiService,
    required StorageService storageService,
  })  : _aiService = aiService,
        _storageService = storageService {
    _history = _storageService.loadQuizHistory();
    _library = _storageService.loadLibrary();
    _tasks = _storageService.loadTasks();
    _dailyGoal = _storageService.loadDailyGoal();
    focusTimer = FocusTimer(
        save: _storageService.saveFocus, initial: _storageService.loadFocus());
  }

  final AIService _aiService;
  final StorageService _storageService;

  StudyAction _selectedAction = StudyAction.summary;
  bool _isLoading = false;
  String? _errorMessage;
  String _lastTextResult = '';
  String _lastQuizTitle = 'Quiz';
  List<QuizQuestion> _quizQuestions = const [];
  List<Flashcard> _flashcards = const [];
  List<QuizResult> _history = const [];
  bool _usedDemoLastRequest = true;
  List<SavedStudy> _library = [];
  String _lastContent = '';
  String _lastExtractedText = '';
  String get lastExtractedText => _lastExtractedText;
  StudyAction _resultAction = StudyAction.summary;
  bool _savingLibrary = false;
  late final FocusTimer focusTimer;
  List<StudyTask> _tasks = [];
  int _dailyGoal = 10;
  int get dailyGoal => _dailyGoal;

  Future<void> setDailyGoal(int value) async {
    if (![5, 10, 15, 20].contains(value)) {
      throw ArgumentError('Meta diária inválida.');
    }
    if (value == _dailyGoal) return;
    await _storageService.saveDailyGoal(value);
    _dailyGoal = value;
    notifyListeners();
  }
  bool _savingTasks = false;
  bool get savingTasks => _savingTasks;
  List<StudyTask> get tasks => List.unmodifiable(
      [..._tasks]..sort((a, b) => a.dueDate.compareTo(b.dueDate)));

  Future<void> _writeTasks(List<StudyTask> updated) async {
    if (_savingTasks) {
      throw StateError('Aguarde a alteração anterior terminar.');
    }
    _savingTasks = true;
    notifyListeners();
    try {
      await _storageService.saveTasks(updated);
      _tasks = updated;
    } finally {
      _savingTasks = false;
      notifyListeners();
    }
  }

  Future<void> addTask(
      {required String title,
      required String subject,
      required DateTime dueDate}) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Informe o título da tarefa.');
    }
    if (_savingTasks) {
      throw StateError('Aguarde a alteração anterior terminar.');
    }
    await _writeTasks([
      StudyTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title.trim(),
          subject: subject.trim().isEmpty ? 'Geral' : subject.trim(),
          dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day)),
      ..._tasks
    ]);
  }

  Future<void> toggleTask(String id) => _writeTasks([
        for (final task in _tasks)
          if (task.id == id) task.toggle() else task,
      ]);

  Future<void> updateTask(StudyTask task) => _writeTasks([
        for (final item in _tasks)
          if (item.id == task.id) task else item,
      ]);

  Future<void> deleteTask(String id) =>
      _writeTasks(_tasks.where((task) => task.id != id).toList());

  @override
  void dispose() {
    focusTimer.dispose();
    super.dispose();
  }

  List<SavedStudy> get library => List.unmodifiable(_library);
  bool get savingLibrary => _savingLibrary;
  bool get currentResultSaved =>
      _lastTextResult.isNotEmpty &&
      _library.any((item) => item.text == _lastTextResult);

  int questionsOn(DateTime date) => _history.where((item) {
        final day = item.createdAt.toLocal();
        return day.year == date.year &&
            day.month == date.month &&
            day.day == date.day;
      }).fold(0, (sum, item) => sum + item.total);

  Future<void> saveCurrentResult() async {
    if (_savingLibrary || currentResultSaved || _lastTextResult.isEmpty) return;
    if (_library.length >= 50) {
      throw StateError(
          'Sua biblioteca tem 50 materiais. Remova um para salvar outro.');
    }
    _savingLibrary = true;
    notifyListeners();
    final now = DateTime.now();
    final title = _lastContent.replaceAll(RegExp(r'\s+'), ' ').trim();
    final item = SavedStudy(
      id: now.microsecondsSinceEpoch.toString(),
      title: title.length > 80 ? '${title.substring(0, 80)}…' : title,
      kind: _resultAction == StudyAction.summary ? 'Resumo' : 'Explicação',
      text: _lastTextResult,
      createdAt: now,
    );
    try {
      final updated = [item, ..._library];
      await _storageService.saveLibrary(updated);
      _library = updated;
    } finally {
      _savingLibrary = false;
      notifyListeners();
    }
  }

  Future<void> removeSavedStudy(String id) async {
    if (_savingLibrary) return;
    _savingLibrary = true;
    notifyListeners();
    try {
      final updated = _library.where((item) => item.id != id).toList();
      await _storageService.saveLibrary(updated);
      _library = updated;
    } finally {
      _savingLibrary = false;
      notifyListeners();
    }
  }

  void reshuffleQuiz() {
    _quizQuestions = balanceQuizOptions(_quizQuestions);
    notifyListeners();
  }

  StudyAction get selectedAction => _selectedAction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get lastTextResult => _lastTextResult;
  String get lastQuizTitle => _lastQuizTitle;
  List<QuizQuestion> get quizQuestions => _quizQuestions;
  List<Flashcard> get flashcards => _flashcards;
  List<QuizResult> get history => List.unmodifiable(_history);
  bool get aiConfigured => _aiService.isConfigured;
  bool get usedDemoLastRequest => _usedDemoLastRequest;

  String get sampleContent => DemoAIService.sampleContent;

  int get quizzesCompleted => _history.length;

  int get totalQuestions => _history.fold(0, (sum, item) => sum + item.total);

  int get totalCorrect => _history.fold(0, (sum, item) => sum + item.score);

  double get averagePercentage {
    if (_history.isEmpty) return 0;
    final sum =
        _history.fold<double>(0, (value, item) => value + item.percentage);
    return sum / _history.length;
  }

  int get bestPercentage {
    if (_history.isEmpty) return 0;
    return _history
        .map((item) => item.percentage.round())
        .reduce((a, b) => a > b ? a : b);
  }

  List<double> get recentPercentages => _history
      .take(7)
      .toList()
      .reversed
      .map((item) => item.percentage)
      .toList(growable: false);

  void selectAction(StudyAction action) {
    if (_isLoading) return;
    _selectedAction = action;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> runAction({
    required String content,
    String explanationMode = 'simple',
    int questionCount = 10,
    String difficulty = 'medium',
    StudyImage? image,
  }) async {
    if (_isLoading) return false;
    final trimmed = content.trim();
    if (trimmed.isEmpty && image == null) {
      _errorMessage = 'Digite um tema ou cole um texto para começar.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _lastTextResult = '';
    _lastExtractedText = '';
    notifyListeners();

    try {
      final response = await _aiService.process(
        action: _selectedAction,
        content: trimmed,
        explanationMode: explanationMode,
        questionCount: questionCount,
        difficulty: difficulty,
        image: image,
      );

      _usedDemoLastRequest = response.usedDemo;
      final data = response.data;
      _lastExtractedText = (data['extractedText'] ?? '').toString();

      switch (_selectedAction) {
        case StudyAction.summary:
        case StudyAction.explanation:
          _lastTextResult =
              (data['result'] ?? data['resultado'] ?? '').toString();
          if (_lastTextResult.isEmpty) {
            throw Exception('A IA não retornou um texto válido.');
          }
          _lastContent = trimmed.isNotEmpty ? trimmed : _lastExtractedText;
          _resultAction = _selectedAction;
          break;

        case StudyAction.quiz:
          final raw = data['questions'] ?? data['perguntas'] ?? const [];
          final questions = (raw as List)
              .whereType<Map>()
              .map(
                (item) => QuizQuestion.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .where((question) => question.options.length >= 2)
              .toList();

          if (questions.isEmpty) {
            throw Exception('A IA não retornou perguntas válidas.');
          }

          _lastQuizTitle =
              (data['title'] ?? data['titulo'] ?? 'Quiz gerado por IA')
                  .toString();
          _quizQuestions = balanceQuizOptions(questions);
          break;

        case StudyAction.flashcards:
          final raw = data['cards'] ?? data['flashcards'] ?? const [];
          final cards = (raw as List)
              .whereType<Map>()
              .map(
                (item) => Flashcard.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();

          if (cards.isEmpty) {
            throw Exception('A IA não retornou flashcards válidos.');
          }

          _flashcards = cards;
          break;
      }

      return true;
    } catch (error) {
      _errorMessage = 'Não foi possível processar o conteúdo: $error';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveQuizResult({
    required int score,
    required int total,
  }) async {
    final result = QuizResult(
      topic: _lastQuizTitle,
      score: score,
      total: total,
      createdAt: DateTime.now(),
    );

    _history = [result, ..._history].take(30).toList();
    notifyListeners();
    await _storageService.saveQuizHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _storageService.clearQuizHistory();
  }

  Future<void> seedDemoHistory() async {
    final now = DateTime.now();
    _history = [
      QuizResult(
        topic: 'Provider no Flutter',
        score: 5,
        total: 5,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      QuizResult(
        topic: 'Widgets e Navegação',
        score: 4,
        total: 5,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      QuizResult(
        topic: 'Dart e Assincronismo',
        score: 4,
        total: 6,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      QuizResult(
        topic: 'Gerenciamento de Estado',
        score: 7,
        total: 8,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      QuizResult(
        topic: 'Fundamentos Flutter',
        score: 3,
        total: 5,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    notifyListeners();
    await _storageService.saveQuizHistory(_history);
  }
}
