import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_ai/providers/study_provider.dart';
import 'package:study_ai/screens/study_screen.dart';
import 'package:study_ai/services/ai_service.dart';
import 'package:study_ai/services/storage_service.dart';

void main() {
  testWidgets('uma palavra atravessa tela e provider e gera resumo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var requests = 0;
    const result = 'Valorant é um jogo de tiro tático em equipes.';
    final study = StudyProvider(
      storageService: StorageService(prefs),
      aiService: AIService(
        apiEndpoint: 'https://example.test/study',
        apiKey: 'test',
        client: MockClient((request) async {
          requests++;
          final body = jsonDecode(request.body);
          expect(body['content'], 'Valorant');
          expect(body['inputMode'], 'topic');
          return http.Response(jsonEncode({'result': result}), 200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        }),
      ),
    );
    addTearDown(study.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: study,
      child: const MaterialApp(home: Scaffold(body: StudyScreen())),
    ));
    expect(find.text('mín. 30 caracteres'), findsNothing);
    await tester.enterText(
        find.byKey(const Key('study-content-field')), 'Valorant');
    await tester.scrollUntilVisible(
      find.byKey(const Key('generate-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('generate-button')));
    await tester.pumpAndSettle();
    expect(requests, 1);
    expect(study.lastTextResult, result);
    expect(find.text(result), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('save-study-button')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('save-study-button')));
    await tester.pumpAndSettle();
    expect(study.library.single.text, result);
    expect(find.text('Salvo na biblioteca'), findsOneWidget);
    expect(await study.runAction(content: '   '), isFalse);
    expect(requests, 1);
    await tester.pumpAndSettle();
  });
}
