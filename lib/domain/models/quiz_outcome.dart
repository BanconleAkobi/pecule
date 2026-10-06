import 'package:pecule/domain/models/user_level.dart';

class QuizOutcome {
  const QuizOutcome({
    required this.correctAnswerCount,
    required this.level,
    required this.mistakenLessonIds,
  });

  /// Questionnaire passé : niveau Découverte (cahier des charges, section 4.2).
  const QuizOutcome.skipped()
    : correctAnswerCount = 0,
      level = UserLevel.discovery,
      mistakenLessonIds = const [];

  final int correctAnswerCount;
  final UserLevel level;
  final List<String> mistakenLessonIds;
}
