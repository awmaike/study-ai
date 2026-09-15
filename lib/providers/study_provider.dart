import 'package:flutter/foundation.dart';

import '../models/flashcard.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/study_action.dart';
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

  int get totalQuestions =>
      _history.fold(0, (sum, item) => sum + item.total);

  int get totalCorrect =>
      _history.fold(0, (sum, item) => sum + item.score);

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
    _selectedAction = action;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> runAction({
    required String content,
    String explanationMode = 'simple',
  }) async {
    final trimmed = content.trim();
    if (trimmed.length < 30) {
      _errorMessage =
          'Cole um conteúdo um pouco maior (pelo menos 30 caracteres).';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _lastTextResult = '';
    notifyListeners();

    try {
      final response = await _aiService.process(
        action: _selectedAction,
        content: trimmed,
        explanationMode: explanationMode,
      );

      _usedDemoLastRequest = response.usedDemo;
      final data = response.data;

      switch (_selectedAction) {
        case StudyAction.summary:
        case StudyAction.explanation:
          _lastTextResult =
              (data['result'] ?? data['resultado'] ?? '').toString();
          if (_lastTextResult.isEmpty) {
            throw Exception('A IA não retornou um texto válido.');
          }
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
          _quizQuestions = questions;
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
