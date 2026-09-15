class QuizResult {
  const QuizResult({
    required this.topic,
    required this.score,
    required this.total,
    required this.createdAt,
  });

  final String topic;
  final int score;
  final int total;
  final DateTime createdAt;

  double get percentage => total == 0 ? 0 : (score / total) * 100;

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'score': score,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      topic: (json['topic'] ?? 'Quiz').toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
