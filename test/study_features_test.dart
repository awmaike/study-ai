import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_ai/models/quiz_question.dart';
import 'package:study_ai/models/quiz_result.dart';
import 'package:study_ai/models/study_action.dart';
import 'package:study_ai/providers/study_provider.dart';
import 'package:study_ai/screens/home_screen.dart';
import 'package:study_ai/screens/library_screen.dart';
import 'package:study_ai/screens/quiz_screen.dart';
import 'package:study_ai/services/ai_service.dart';
import 'package:study_ai/services/quiz_shuffle.dart';
import 'package:study_ai/services/storage_service.dart';
import 'package:study_ai/theme/app_theme.dart';

const capture = bool.fromEnvironment('CAPTURE_UI');
const captureKey = Key('capture');

Future<void> screenshot(WidgetTester tester, String name) async {
  if (!capture) return;
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(captureKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.5);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('build/ui-review/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

Future<StudyProvider> makeStudy() async {
  final prefs = await SharedPreferences.getInstance();
  return StudyProvider(
      storageService: StorageService(prefs),
      aiService: AIService(
        apiEndpoint: 'https://example.test/study',
        apiKey: 'test',
        client: MockClient((request) async {
          final action = jsonDecode(request.body)['action'];
          final data = action == 'quiz'
              ? {
                  'title': 'Quiz: ciclo da água',
                  'questions': [
                    {
                      'question':
                          'Qual processo transforma água líquida em vapor?',
                      'options': [
                        'Condensação',
                        'Evaporação',
                        'Infiltração',
                        'Precipitação'
                      ],
                      'correctIndex': 1,
                      'explanation':
                          'Na evaporação, a água líquida passa para o estado gasoso.'
                    },
                    {
                      'question': 'Qual processo forma gotículas nas nuvens?',
                      'options': [
                        'Transpiração',
                        'Condensação',
                        'Infiltração',
                        'Escoamento'
                      ],
                      'correctIndex': 1,
                      'explanation':
                          'Ao esfriar, o vapor se condensa em gotículas.'
                    },
                  ],
                }
              : {
                  'result': 'A fotossíntese transforma energia luminosa em energia química. '
                      'Nas plantas, ocorre nos cloroplastos. Água e gás carbônico são utilizados '
                      'para produzir açúcares, e oxigênio é liberado. Os açúcares contribuem para '
                      'o crescimento e o funcionamento da planta.'
                };
          return http.Response(jsonEncode(data), 200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        }),
      ));
}

Future<void> mount(WidgetTester tester, StudyProvider study, Widget screen,
    {bool dark = false}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  if (capture) {
    final font = File('C:/Windows/Fonts/segoeui.ttf');
    if (font.existsSync()) {
      await tester.runAsync(() async {
        for (final family in ['Roboto', 'Ahem']) {
          final loader = FontLoader(family)
            ..addFont(
                Future.value(ByteData.sublistView(font.readAsBytesSync())));
          await loader.load();
        }
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
    }
  }
  await tester.pumpWidget(ChangeNotifierProvider.value(
      value: study,
      child: RepaintBoundary(
          key: captureKey,
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: screen))));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('equilibra A–D, preserva respostas e não modifica os originais', () {
    final original = List.generate(
        10,
        (i) => QuizQuestion(
            question: 'Questão $i',
            options: ['erro A $i', 'correta $i', 'erro C $i', 'erro D $i'],
            correctIndex: 1,
            explanation: 'Motivo $i'));
    final sequences = <String>{};
    for (var seed = 0; seed < 100; seed++) {
      final result = balanceQuizOptions(original, random: Random(seed));
      final counts = List.filled(4, 0);
      for (var i = 0; i < result.length; i++) {
        final q = result[i];
        counts[q.correctIndex]++;
        expect(q.options[q.correctIndex], 'correta $i');
        expect(q.options.toSet(), original[i].options.toSet());
        expect(q.explanation, original[i].explanation);
        expect(original[i].correctIndex, 1);
      }
      expect(counts.every((count) => count == 2 || count == 3), isTrue);
      sequences.add(result.map((q) => q.correctIndex).join());
    }
    expect(sequences.length, greaterThan(90));
    expect(balanceQuizOptions([]), isEmpty);
  });

  test('biblioteca persiste, evita duplicação e remove material', () async {
    final study = await makeStudy();
    expect(await study.runAction(content: 'Fotossíntese'), isTrue);
    await study.saveCurrentResult();
    await study.saveCurrentResult();
    expect(study.library, hasLength(1));
    final restored = await makeStudy();
    expect(restored.library.single.text, study.lastTextResult);
    expect(restored.library.single.title, 'Fotossíntese');
    await restored.removeSavedStudy(restored.library.single.id);
    expect((await makeStudy()).library, isEmpty);
  });

  test('meta conta somente quizzes concluídos na data escolhida', () async {
    final prefs = await SharedPreferences.getInstance();
    await StorageService(prefs).saveQuizHistory([
      QuizResult(
          topic: 'Hoje',
          score: 3,
          total: 5,
          createdAt: DateTime(2026, 9, 15, 10)),
      QuizResult(
          topic: 'Hoje também',
          score: 4,
          total: 10,
          createdAt: DateTime(2026, 9, 15, 12)),
      QuizResult(
          topic: 'Ontem',
          score: 10,
          total: 10,
          createdAt: DateTime(2026, 9, 14)),
    ]);
    final study = await makeStudy();
    expect(study.questionsOn(DateTime(2026, 9, 15)), 15);
    expect(study.questionsOn(DateTime(2026, 9, 16)), 0);
  });

  testWidgets('quiz corrige alternativas embaralhadas e revisa apenas erros',
      (tester) async {
    final study = await makeStudy();
    study.selectAction(StudyAction.quiz);
    expect(
        await study.runAction(
            content: 'O ciclo da água envolve evaporação e condensação.'),
        isTrue);
    await mount(tester, study, const QuizScreen());
    for (var i = 0; i < 2; i++) {
      final question = study.quizQuestions[i];
      final answer =
          i == 0 ? question.correctIndex : (question.correctIndex + 1) % 4;
      await tester.tap(find.text(question.options[answer]));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Confirmar resposta'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Confirmar resposta'));
      await tester.pumpAndSettle();
      final next = find.text(i == 0 ? 'Próxima pergunta' : 'Ver resultado');
      await tester.scrollUntilVisible(next, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('Você acertou 1 de 2 questões.'), findsOneWidget);
    expect(study.history.single.score, 1);
    await tester.scrollUntilVisible(
        find.byKey(const Key('review-errors-filter')), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('review-errors-filter')));
    await tester.pumpAndSettle();
    expect(find.text('1. ${study.quizQuestions.first.question}'), findsNothing);
    expect(
        find.text('2. ${study.quizQuestions.last.question}'), findsOneWidget);
    await screenshot(tester, 'quiz-review');
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
        'home e biblioteca funcionam no tema ${dark ? "escuro" : "claro"}',
        (tester) async {
      final study = await makeStudy();
      await study.runAction(content: 'Fotossíntese');
      await study.saveCurrentResult();
      await mount(
          tester, study, Scaffold(body: HomeScreen(onOpenStudy: ([action]) {})),
          dark: dark);
      await screenshot(tester, 'home-${dark ? "dark" : "light"}');
      await tester.tap(find.byTooltip('Minha biblioteca'));
      await tester.pumpAndSettle();
      expect(find.byType(LibraryScreen), findsOneWidget);
      await tester.tap(find.text('Fotossíntese'));
      await tester.pumpAndSettle();
      expect(find.text(study.library.single.text), findsOneWidget);
      await screenshot(tester, 'library-${dark ? "dark" : "light"}');
      await tester.enterText(find.byType(TextField), 'inexistente');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum material encontrado.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
