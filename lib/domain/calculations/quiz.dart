import 'package:pecule/domain/models/quiz_outcome.dart';
import 'package:pecule/domain/models/quiz_question.dart';
import 'package:pecule/domain/models/user_level.dart';

const _maxCorrectForDiscovery = 1;
const _maxCorrectForInitiated = 3;

UserLevel levelForCorrectAnswers(int correctAnswerCount) {
  if (correctAnswerCount <= _maxCorrectForDiscovery) return UserLevel.discovery;
  if (correctAnswerCount <= _maxCorrectForInitiated) return UserLevel.initiated;
  return UserLevel.comfortable;
}

/// [answers] : index du choix retenu pour chaque question, dans l'ordre.
QuizOutcome evaluateQuiz(
  List<QuizQuestion> questions, {
  required List<int> answers,
}) {
  if (answers.length != questions.length) {
    throw ArgumentError.value(
      answers.length,
      'answers',
      'une réponse attendue par question (${questions.length})',
    );
  }

  final mistakenLessonIds = [
    for (var index = 0; index < questions.length; index++)
      if (answers[index] != questions[index].correctChoiceIndex)
        questions[index].lessonId,
  ];
  final correctAnswerCount = questions.length - mistakenLessonIds.length;

  return QuizOutcome(
    correctAnswerCount: correctAnswerCount,
    level: levelForCorrectAnswers(correctAnswerCount),
    mistakenLessonIds: mistakenLessonIds,
  );
}
