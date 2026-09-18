import 'package:flutter/material.dart';

import '../models/quiz_question.dart';

class QuizReview extends StatefulWidget {
  const QuizReview({super.key, required this.questions, required this.answers});

  final List<QuizQuestion> questions;
  final Map<int, int> answers;

  @override
  State<QuizReview> createState() => _QuizReviewState();
}

class _QuizReviewState extends State<QuizReview> {
  bool _onlyErrors = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final errors = widget.questions
        .asMap()
        .entries
        .where((entry) => widget.answers[entry.key] != entry.value.correctIndex)
        .length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Aprenda com cada resposta',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text('Abra uma questão para revisar o raciocínio.',
          style: TextStyle(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 12),
      FilterChip(
        showCheckmark: false,
        key: const Key('review-errors-filter'),
        selected: _onlyErrors,
        onSelected: (value) => setState(() => _onlyErrors = value),
        label: Text('Só os erros ($errors)'),
        avatar: const Icon(Icons.manage_search_rounded, size: 18),
      ),
      const SizedBox(height: 12),
      if (_onlyErrors && errors == 0)
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nenhum erro para revisar. Você acertou todas!')),
      for (var i = 0; i < widget.questions.length; i++)
        if (!_onlyErrors ||
            widget.answers[i] != widget.questions[i].correctIndex)
          Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              key: ValueKey('review-$i-$_onlyErrors'),
              initiallyExpanded: _onlyErrors,
              leading: Icon(
                  widget.answers[i] == widget.questions[i].correctIndex
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  color: widget.answers[i] == widget.questions[i].correctIndex
                      ? scheme.primary
                      : scheme.error),
              title: Text('${i + 1}. ${widget.questions[i].question}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (widget.answers[i] != null)
                  Text(
                      'Sua resposta: ${String.fromCharCode(65 + widget.answers[i]!)}. ${widget.questions[i].options[widget.answers[i]!]}'),
                const SizedBox(height: 8),
                Text(
                    'Resposta correta: ${String.fromCharCode(65 + widget.questions[i].correctIndex)}. ${widget.questions[i].options[widget.questions[i].correctIndex]}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: scheme.primary)),
                const SizedBox(height: 12),
                Text(widget.questions[i].explanation,
                    style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
    ]);
  }
}
