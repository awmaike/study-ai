import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/study_provider.dart';
import '../widgets/mini_line_chart.dart';
import '../widgets/stat_card.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final scheme = Theme.of(context).colorScheme;
    final average = study.averagePercentage.round();
    final chartValues = study.recentPercentages.isEmpty
        ? <double>[55, 68, 63, 74, 82]
        : study.recentPercentages;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        Text(
          'Desempenho',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Acompanhe sua evolução nos quizzes.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: average / 100,
                      strokeWidth: 11,
                      backgroundColor: scheme.surfaceVariant,
                    ),
                    Center(
                      child: Text(
                        '$average%',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Média geral',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      study.quizzesCompleted == 0
                          ? 'Faça seu primeiro quiz para começar.'
                          : average >= 80
                              ? 'Ótimo desempenho. Continue assim!'
                              : average >= 60
                                  ? 'Você está evoluindo bem.'
                                  : 'Revise os conteúdos e tente novamente.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Quizzes',
                value: '${study.quizzesCompleted}',
                icon: Icons.quiz_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Melhor nota',
                value: '${study.bestPercentage}%',
                icon: Icons.emoji_events_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Questões',
                value: '${study.totalQuestions}',
                icon: Icons.help_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Acertos',
                value: '${study.totalCorrect}',
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'Evolução recente',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          child: Column(
            children: [
              MiniLineChart(values: chartValues, height: 170),
              if (study.history.isEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Prévia visual — seus resultados reais aparecerão aqui.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                'Histórico',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (study.history.isNotEmpty)
              Text(
                '${study.history.length} registro(s)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (study.history.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 44,
                  color: scheme.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ainda não há resultados.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete um quiz ou carregue dados de demonstração em Ajustes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          )
        else
          ...study.history.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.55),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Text(
                        '${item.percentage.round()}%',
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.topic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.score}/${item.total} acertos • ${_formatDate(item.createdAt)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
