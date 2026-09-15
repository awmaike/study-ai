import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai/models/quiz_question.dart';

void main() {
  test('QuizQuestion converte JSON em objeto Dart', () {
    final question = QuizQuestion.fromJson({
      'question': 'O que é Flutter?',
      'options': ['Framework', 'Banco', 'Sistema', 'Editor'],
      'correctIndex': 0,
      'explanation': 'Flutter é um framework.',
    });

    expect(question.question, 'O que é Flutter?');
    expect(question.options.length, 4);
    expect(question.correctIndex, 0);
  });
}
