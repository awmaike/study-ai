import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_ai/models/study_action.dart';
import 'package:study_ai/providers/study_provider.dart';
import 'package:study_ai/screens/study_screen.dart';
import 'package:study_ai/services/ai_service.dart';
import 'package:study_ai/services/storage_service.dart';

void main() {
  testWidgets('quiz aberto em nova rota conserva o provider da conta',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final study = StudyProvider(
      storageService: StorageService(prefs, userId: 'conta-teste'),
      aiService: AIService(
        apiEndpoint: 'https://example.test/study-ai',
        apiKey: 'public-key',
        client: MockClient((_) async => http.Response(
              jsonEncode({
                'title': 'Quiz de teste',
                'questions': [
                  {
                    'question': 'Qual é a resposta correta?',
                    'options': ['Primeira', 'Segunda', 'Terceira', 'Quarta'],
                    'correctIndex': 1,
                    'explanation': 'A segunda opção está correta.',
                  },
                ],
              }),
              200,
            )),
      ),
    )..selectAction(StudyAction.quiz);
    addTearDown(study.dispose);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: study,
      child: const MaterialApp(home: Scaffold(body: StudyScreen())),
    ));
    await tester.enterText(find.byKey(const Key('study-content-field')),
        'O ciclo da água inclui evaporação, condensação e precipitação.');
    await tester.scrollUntilVisible(
        find.byKey(const Key('generate-button')), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('generate-button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Qual é a resposta correta?'), findsOneWidget);
    expect(find.text('Pergunta 1 de 1'), findsOneWidget);
  });
}
