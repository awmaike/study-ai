import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_ai/app.dart';
import 'package:study_ai/providers/study_provider.dart';
import 'package:study_ai/providers/theme_provider.dart';
import 'package:study_ai/services/ai_service.dart';
import 'package:study_ai/services/storage_service.dart';

void main() {
  testWidgets('botões da Home e barra inferior trocam de tela', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
          ChangeNotifierProvider(
            create: (_) => StudyProvider(
              aiService: AIService(),
              storageService: storage,
            ),
          ),
        ],
        child: const StudyAIApp(),
      ),
    );

    expect(find.text('StudyAI'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-start-button')));
    await tester.pumpAndSettle();
    expect(find.text('Espaço de Estudos'), findsOneWidget);

    await tester.tap(find.text('Rotina'));
    await tester.pumpAndSettle();
    expect(find.text('Minha rotina'), findsOneWidget);

    await tester.tap(find.text('Progresso'));
    await tester.pumpAndSettle();
    expect(find.text('Desempenho'), findsOneWidget);

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Personalize sua experiência de estudo.'),
        findsOneWidget);
    expect(find.text('IA configurada'), findsNothing);
    expect(find.text('Sobre o projeto'), findsNothing);
  });
}
