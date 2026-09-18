import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_ai/providers/focus_timer.dart';
import 'package:study_ai/screens/routine_screen.dart';
import 'package:study_ai/screens/study_screen.dart';
import 'package:study_ai/screens/library_screen.dart';
import 'package:study_ai/models/study_action.dart';

import 'study_features_test.dart' as helpers;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('foco pausa, retoma e registra uma única conclusão mesmo após reabrir',
      () async {
    var now = DateTime(2026, 9, 15, 10);
    Map<String, dynamic> saved = {};
    final focus = FocusTimer(
        save: (state) async => saved = state, now: () => now, autoTick: false);
    await focus.reset(minutes: 15);
    await focus.start();
    now = now.add(const Duration(minutes: 5));
    expect(focus.remainingSeconds, 600);
    await focus.pause();
    now = now.add(const Duration(minutes: 30));
    expect(focus.remainingSeconds, 600);
    expect(focus.minutesOn(now), 0);
    await focus.start();
    focus.dispose();
    now = now.add(const Duration(minutes: 11));
    final restored = FocusTimer(
        save: (state) async => saved = state,
        initial: saved,
        now: () => now,
        autoTick: false);
    restored.refresh();
    await Future<void>.delayed(Duration.zero);
    expect(restored.completed, isTrue);
    expect(restored.minutesOn(now), 15);
    restored.refresh();
    expect(restored.minutesOn(now), 15);
    final reopened = FocusTimer(
        save: (_) async {}, initial: saved, now: () => now, autoTick: false);
    reopened.refresh();
    expect(reopened.minutesOn(now), 15);
    await restored.reset();
    expect(restored.remainingSeconds, 900);
    expect(restored.minutesOn(now), 15);
    restored.dispose();
    reopened.dispose();
  });

  test('tarefas mantêm matéria, data e conclusão entre aberturas', () async {
    final study = await helpers.makeStudy();
    addTearDown(study.dispose);
    await study.addTask(
        title: 'Revisar widgets',
        subject: 'Flutter',
        dueDate: DateTime(2026, 9, 16));
    final restored = await helpers.makeStudy();
    addTearDown(restored.dispose);
    expect(restored.tasks.single.subject, 'Flutter');
    expect(restored.tasks.single.dueDate, DateTime(2026, 9, 16));
    await restored.toggleTask(restored.tasks.single.id);
    final reopened = await helpers.makeStudy();
    addTearDown(reopened.dispose);
    expect(reopened.tasks.single.completed, isTrue);
    await reopened.deleteTask(reopened.tasks.single.id);
    expect(reopened.tasks, isEmpty);
  });

  testWidgets('rotina cria tarefa e pausa o relógio', (tester) async {
    final study = await helpers.makeStudy();
    addTearDown(study.dispose);
    await helpers.mount(tester, study, const Scaffold(body: RoutineScreen()));
    await tester.tap(find.byTooltip('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Revisar widgets');
    await tester.enterText(find.byType(TextFormField).last, 'Flutter');
    await tester.ensureVisible(find.text('Salvar tarefa'));
    await tester.tap(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();
    expect(study.tasks.single.title, 'Revisar widgets');
    await tester.tap(find.byKey(const Key('focus-toggle')));
    await tester.pump(const Duration(seconds: 2));
    expect(study.focusTimer.running, isTrue);
    await tester.tap(find.byKey(const Key('focus-toggle')));
    await tester.pumpAndSettle();
    expect(study.focusTimer.running, isFalse);
    final remaining = study.focusTimer.remainingSeconds;
    await tester.pump(const Duration(seconds: 5));
    expect(study.focusTimer.remainingSeconds, remaining);
    await helpers.screenshot(tester, 'routine');
    await tester.scrollUntilVisible(
        find.byTooltip('Opções da tarefa').hitTestable(), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byTooltip('Opções da tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField).first, 'Revisar navegação');
    await tester.ensureVisible(find.text('Salvar tarefa'));
    await tester.tap(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();
    expect(study.tasks.single.title, 'Revisar navegação');
    await tester.scrollUntilVisible(find.byType(Checkbox).hitTestable(), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(study.tasks.single.completed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('biblioteca encaminha texto salvo para quiz personalizável',
      (tester) async {
    final study = await helpers.makeStudy();
    addTearDown(study.dispose);
    await study.runAction(content: 'Fotossíntese');
    await study.saveCurrentResult();
    final savedText = study.library.single.text;
    await helpers.mount(tester, study, const LibraryScreen());
    await tester.tap(find.text('Fotossíntese'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Criar quiz deste material'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Criar quiz deste material'));
    await tester.pumpAndSettle();
    expect(find.byType(StudyScreen), findsOneWidget);
    expect(
        tester
            .widget<TextField>(find.byKey(const Key('study-content-field')))
            .controller!
            .text,
        savedText);
    expect(study.selectedAction, StudyAction.quiz);
    final studyScroll = tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(StudyScreen), matching: find.byType(Scrollable))
        .first);
    studyScroll.position.jumpTo(studyScroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(find.text('Seu quiz, no seu ritmo'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ChoiceChip>(find.ancestor(
                of: find.text('15'), matching: find.byType(ChoiceChip)))
            .selected,
        isTrue);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avançado'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ChoiceChip>(find.ancestor(
                of: find.text('Avançado'), matching: find.byType(ChoiceChip)))
            .selected,
        isTrue);
    await helpers.screenshot(tester, 'quiz-settings');
    expect(tester.takeException(), isNull);
  });
}
