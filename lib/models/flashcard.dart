class Flashcard {
  const Flashcard({
    required this.front,
    required this.back,
  });

  final String front;
  final String back;

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      front: (json['front'] ?? json['frente'] ?? 'Pergunta').toString(),
      back: (json['back'] ?? json['verso'] ?? 'Resposta').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'front': front,
        'back': back,
      };
}
