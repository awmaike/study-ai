class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions =
        json['options'] ?? json['alternativas'] ?? json['answers'] ?? const [];

    final options = (rawOptions as List)
        .map((item) => item.toString())
        .toList(growable: false);

    final rawCorrect =
        json['correctIndex'] ?? json['correta'] ?? json['correct_index'] ?? 0;
    final parsedCorrect = rawCorrect is int
        ? rawCorrect
        : int.tryParse(rawCorrect.toString()) ?? 0;

    final maxIndex = options.isEmpty ? 0 : options.length - 1;
    final safeCorrect = parsedCorrect < 0
        ? 0
        : (parsedCorrect > maxIndex ? maxIndex : parsedCorrect);

    return QuizQuestion(
      question: (json['question'] ?? json['pergunta'] ?? 'Pergunta').toString(),
      options: options,
      correctIndex: safeCorrect,
      explanation:
          (json['explanation'] ?? json['explicacao'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}
