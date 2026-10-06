class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.choices,
    required this.correctChoiceIndex,
    required this.lessonId,
  });

  final String prompt;
  final List<String> choices;
  final int correctChoiceIndex;

  /// Leçon conseillée quand la réponse est fausse.
  final String lessonId;
}
