import 'dart:math';

import '../models/quiz_question.dart';

/// Balances correct positions without changing the answer or explanation.
List<QuizQuestion> balanceQuizOptions(List<QuizQuestion> questions,
    {Random? random}) {
  final rng = random ?? Random();
  final groups = <int, List<int>>{};
  for (var i = 0; i < questions.length; i++) {
    groups.putIfAbsent(questions[i].options.length, () => []).add(i);
  }
  final result = List<QuizQuestion>.of(questions);
  for (final entry in groups.entries) {
    final count = entry.key;
    if (count < 2) continue;
    final letters = List.generate(count, (i) => i)..shuffle(rng);
    final targets = List.generate(entry.value.length, (i) => letters[i % count])
      ..shuffle(rng);
    for (var i = 0; i < entry.value.length; i++) {
      final question = questions[entry.value[i]];
      final correct = question.options[question.correctIndex];
      final options = [
        for (var j = 0; j < count; j++)
          if (j != question.correctIndex) question.options[j],
      ]..shuffle(rng);
      options.insert(targets[i], correct);
      result[entry.value[i]] = QuizQuestion(
        question: question.question,
        options: List.unmodifiable(options),
        correctIndex: targets[i],
        explanation: question.explanation,
      );
    }
  }
  return result;
}
