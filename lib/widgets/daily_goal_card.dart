import 'package:flutter/material.dart';
import 'study_glyph.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard(
      {super.key,
      required this.completed,
      required this.goal,
      required this.onStart});

  final int completed;
  final int goal;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = completed >= goal;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          StudyGlyph(done ? StudyGlyphKind.quiz : StudyGlyphKind.progress,
              color: scheme.onSecondaryContainer, size: 30),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  done
                      ? 'Meta do dia concluída!'
                      : 'Um pouco hoje. Mais longe amanhã.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 14),
        Text(
            done
                ? 'Você já respondeu $completed questões hoje. Continue no seu ritmo.'
                : 'Seu desafio: concluir $goal questões de quiz hoje.',
            style: TextStyle(color: scheme.onSecondaryContainer)),
        const SizedBox(height: 14),
        LinearProgressIndicator(
            value: (completed / goal).clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: Text('$completed / $goal questões',
                  style: TextStyle(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700))),
          TextButton(
              onPressed: onStart,
              child: Text(done ? 'Praticar mais' : 'Começar desafio')),
        ]),
      ]),
    );
  }
}
