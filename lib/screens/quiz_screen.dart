import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/study_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _current = 0;
  int? _selected;
  bool _confirmed = false;
  bool _finished = false;
  bool _saved = false;
  int _score = 0;

  void _confirm(int correctIndex) {
    if (_selected == null || _confirmed) return;

    setState(() {
      _confirmed = true;
      if (_selected == correctIndex) {
        _score++;
      }
    });
  }

  Future<void> _next() async {
    final provider = context.read<StudyProvider>();
    final questions = provider.quizQuestions;

    if (_current >= questions.length - 1) {
      if (!_saved) {
        _saved = true;
        await provider.saveQuizResult(
          score: _score,
          total: questions.length,
        );
      }

      if (!mounted) return;
      setState(() => _finished = true);
      return;
    }

    setState(() {
      _current++;
      _selected = null;
      _confirmed = false;
    });
  }

  void _restart() {
    setState(() {
      _current = 0;
      _selected = null;
      _confirmed = false;
      _finished = false;
      _saved = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final questions = study.quizQuestions;
    final scheme = Theme.of(context).colorScheme;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('Nenhum quiz carregado.'),
        ),
      );
    }

    if (_finished) {
      final percentage = ((_score / questions.length) * 100).round();

      return Scaffold(
        appBar: AppBar(title: const Text('Resultado')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primaryContainer,
                    ),
                    child: Center(
                      child: Text(
                        '$percentage%',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: scheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  percentage >= 80
                      ? 'Excelente trabalho! 🎉'
                      : percentage >= 60
                          ? 'Muito bem! Continue praticando.'
                          : 'Boa tentativa! Vamos revisar?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Você acertou $_score de ${questions.length} questões.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 26),
                LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 12,
                ),
                const SizedBox(height: 30),
                FilledButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Refazer quiz'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Voltar para estudar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[_current];
    final progress = (_current + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(study.lastQuizTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pergunta ${_current + 1} de ${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 9,
              ),
              const SizedBox(height: 26),
              Text(
                question.question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 22),
              ...List.generate(question.options.length, (index) {
                final isSelected = _selected == index;
                final isCorrect = index == question.correctIndex;

                Color? background;
                Color? foreground;

                if (_confirmed && isCorrect) {
                  background = Colors.green.withOpacity(0.14);
                  foreground = Colors.green.shade700;
                } else if (_confirmed && isSelected && !isCorrect) {
                  background = scheme.errorContainer;
                  foreground = scheme.onErrorContainer;
                } else if (isSelected) {
                  background = scheme.primaryContainer;
                  foreground = scheme.onPrimaryContainer;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: background ?? scheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: _confirmed
                          ? null
                          : () => setState(() => _selected = index),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? scheme.primary
                                : scheme.outlineVariant,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? scheme.primary
                                    : scheme.surfaceVariant,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? scheme.onPrimary
                                        : scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                            ),
                            if (_confirmed && isCorrect)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              )
                            else if (_confirmed && isSelected && !isCorrect)
                              Icon(
                                Icons.cancel_rounded,
                                color: scheme.error,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              if (_confirmed) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question.explanation,
                          style: TextStyle(
                            color: scheme.onSecondaryContainer,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: _confirmed
                    ? FilledButton(
                        onPressed: _next,
                        child: Text(
                          _current == questions.length - 1
                              ? 'Ver resultado'
                              : 'Próxima pergunta',
                        ),
                      )
                    : FilledButton(
                        onPressed: _selected == null
                            ? null
                            : () => _confirm(question.correctIndex),
                        child: const Text('Confirmar resposta'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
