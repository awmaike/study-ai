import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/study_action.dart';
import 'demo_ai_service.dart';

class AIResponse {
  const AIResponse({
    required this.data,
    required this.usedDemo,
  });

  final Map<String, dynamic> data;
  final bool usedDemo;
}

class AIService {
  AIService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final DemoAIService _demo = DemoAIService();

  static const String endpoint =
      String.fromEnvironment('AI_ENDPOINT', defaultValue: '');
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  bool get isConfigured =>
      endpoint.trim().isNotEmpty && publishableKey.trim().isNotEmpty;

  Future<AIResponse> process({
    required StudyAction action,
    required String content,
    String explanationMode = 'simple',
  }) async {
    if (!isConfigured) {
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
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'apikey': publishableKey,
            },
            body: jsonEncode({
              'action': action.apiValue,
              'content': content,
              'mode': explanationMode,
            }),
          )
          .timeout(const Duration(seconds: 35));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Servidor respondeu com status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Resposta da IA em formato inesperado.');
      }

      return AIResponse(data: decoded, usedDemo: false);
    } on TimeoutException {
      return AIResponse(
        data: _demo.process(
          action: action,
          content: content,
          explanationMode: explanationMode,
        ),
        usedDemo: true,
      );
    } catch (_) {
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
}
