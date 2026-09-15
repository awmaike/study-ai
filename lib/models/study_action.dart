enum StudyAction {
  summary,
  explanation,
  quiz,
  flashcards,
}

extension StudyActionX on StudyAction {
  String get apiValue {
    switch (this) {
      case StudyAction.summary:
        return 'summary';
      case StudyAction.explanation:
        return 'explanation';
      case StudyAction.quiz:
        return 'quiz';
      case StudyAction.flashcards:
        return 'flashcards';
    }
  }

  String get label {
    switch (this) {
      case StudyAction.summary:
        return 'Resumir';
      case StudyAction.explanation:
        return 'Explicar';
      case StudyAction.quiz:
        return 'Criar Quiz';
      case StudyAction.flashcards:
        return 'Flashcards';
    }
  }
}
