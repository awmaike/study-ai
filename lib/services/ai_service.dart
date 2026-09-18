import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/study_action.dart';
import '../models/study_input.dart';
import '../models/study_image.dart';
import 'demo_ai_service.dart';

class AIResponse {
  const AIResponse({
    required this.data,
    required this.usedDemo,
  });

  final Map<String, dynamic> data;
  final bool usedDemo;
}

class StudyRequestException implements Exception {
  const StudyRequestException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AIService {
  AIService(
      {http.Client? client,
      String? apiEndpoint,
      String? apiKey,
      String? Function()? accessToken})
      : _client = client ?? http.Client(),
        _endpoint = apiEndpoint ?? endpoint,
        _publishableKey = apiKey ?? publishableKey,
        _accessToken = accessToken;

  final http.Client _client;
  final String _endpoint;
  final String _publishableKey;
  final String? Function()? _accessToken;
  final DemoAIService _demo = DemoAIService();

  static const String endpoint =
      String.fromEnvironment('AI_ENDPOINT', defaultValue: '');
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  bool get isConfigured =>
      _endpoint.trim().isNotEmpty && _publishableKey.trim().isNotEmpty;

  Future<AIResponse> process({
    required StudyAction action,
    required String content,
    String explanationMode = 'simple',
    int questionCount = 10,
    String difficulty = 'medium',
    StudyImage? image,
  }) async {
    if (content.trim().isEmpty && image == null) {
      throw Exception('Digite um tema ou cole um texto para começar.');
    }
    if (image != null &&
        (image.bytes.isEmpty || image.bytes.length > StudyImage.maxBytes)) {
      throw const StudyRequestException(
          'A foto está vazia ou é muito grande. Escolha outra imagem.');
    }
    if (![5, 10, 15].contains(questionCount) ||
        !['easy', 'medium', 'hard'].contains(difficulty)) {
      throw ArgumentError('Configuração de quiz inválida.');
    }
    final topic = image == null && isStudyTopic(content);
    final requiresAI = action == StudyAction.quiz || topic || image != null;
    if (!isConfigured) {
      if (requiresAI) {
        throw Exception(
          'Conecte a IA para estudar um tema ou gerar um quiz. '
          'Inicie o aplicativo pelo inicializador configurado.',
        );
      }
      return AIResponse(
        data: _demo.process(
          action: action,
          content: content,
          explanationMode: explanationMode,
        ),
        usedDemo: true,
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'apikey': _publishableKey,
              if (_accessToken?.call() case final token?)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'action': action.apiValue,
              'content': content,
              'mode': explanationMode,
              'inputMode': topic ? 'topic' : 'text',
              'questionCount': questionCount,
              'difficulty': difficulty,
              if (image != null) 'image': image.toJson(),
            }),
          )
          .timeout(Duration(seconds: image == null ? 60 : 100));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (image != null) {
          final error = jsonDecode(response.body);
          throw StudyRequestException(error is Map && error['error'] is String
              ? error['error'] as String
              : 'Não foi possível ler a foto. Tente uma imagem mais nítida.');
        }
        throw Exception(
          'Servidor respondeu com status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Resposta da IA em formato inesperado.');
      }

      if (action == StudyAction.quiz) {
        final questions = decoded['questions'];
        if (questions is! List ||
            questions.isEmpty ||
            questions.length > questionCount ||
            (topic && questions.length != questionCount) ||
            questions.any((q) => !_isValidQuestion(q))) {
          throw const FormatException('Quiz inválido.');
        }
      }

      return AIResponse(data: decoded, usedDemo: false);
    } on StudyRequestException {
      rethrow;
    } on TimeoutException {
      if (requiresAI) {
        throw Exception(
            'A IA demorou para responder. Tente gerar o material novamente.');
      }
      return AIResponse(
        data: _demo.process(
          action: action,
          content: content,
          explanationMode: explanationMode,
        ),
        usedDemo: true,
      );
    } catch (_) {
      if (requiresAI) {
        throw Exception(
          'Não foi possível gerar o material agora. '
          'Verifique sua conexão e tente novamente. Se persistir, detalhe melhor o assunto.',
        );
      }
      return AIResponse(
        data: _demo.process(
          action: action,
          content: content,
          explanationMode: explanationMode,
        ),
        usedDemo: true,
      );
    }
  }

  bool _isValidQuestion(dynamic question) {
    if (question is! Map) return false;
    final options = question['options'];
    final index = question['correctIndex'];
    return question['question'] is String &&
        (question['question'] as String).trim().isNotEmpty &&
        question['explanation'] is String &&
        (question['explanation'] as String).trim().isNotEmpty &&
        options is List &&
        options.length == 4 &&
        options.every((o) => o is String && o.trim().isNotEmpty) &&
        options.map((o) => (o as String).trim().toLowerCase()).toSet().length ==
            4 &&
        index is int &&
        index >= 0 &&
        index < 4;
  }
}
