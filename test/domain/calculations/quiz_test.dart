import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/quiz.dart';
import 'package:pecule/domain/models/quiz_outcome.dart';
import 'package:pecule/domain/models/quiz_question.dart';
import 'package:pecule/domain/models/user_level.dart';

QuizQuestion questionAbout(String lessonId) => QuizQuestion(
  prompt: 'Question sur $lessonId',
  choices: const ['A', 'B', 'C', 'D'],
  correctChoiceIndex: 1,
  lessonId: lessonId,
);

void main() {
  group('niveau', () {
    test('0 ou 1 bonne réponse donne Découverte', () {
      expect(levelForCorrectAnswers(0), UserLevel.discovery);
      expect(levelForCorrectAnswers(1), UserLevel.discovery);
    });

    test('2 ou 3 bonnes réponses donnent Initié', () {
      expect(levelForCorrectAnswers(2), UserLevel.initiated);
      expect(levelForCorrectAnswers(3), UserLevel.initiated);
    });

    test('4 ou 5 bonnes réponses donnent À l\'aise', () {
      expect(levelForCorrectAnswers(4), UserLevel.comfortable);
      expect(levelForCorrectAnswers(5), UserLevel.comfortable);
    });
  });

  group('correction du questionnaire', () {
    final questions = [
      questionAbout('actions'),
      questionAbout('rendement'),
      questionAbout('volatilite'),
      questionAbout('diversification'),
      questionAbout('dca'),
    ];

    test('compte les bonnes réponses et en déduit le niveau', () {
      final outcome = evaluateQuiz(questions, answers: [1, 1, 0, 1, 3]);

      expect(outcome.correctAnswerCount, 3);
      expect(outcome.level, UserLevel.initiated);
    });

    test(
      'renvoie les leçons liées aux erreurs, dans l\'ordre des questions',
      () {
        final outcome = evaluateQuiz(questions, answers: [1, 1, 0, 1, 3]);

        expect(outcome.mistakenLessonIds, ['volatilite', 'dca']);
      },
    );

    test('refuse un nombre de réponses différent du nombre de questions', () {
      expect(
        () => evaluateQuiz(questions, answers: [1, 1]),
        throwsArgumentError,
      );
    });
  });

  test('un questionnaire passé donne Découverte, sans erreur', () {
    const outcome = QuizOutcome.skipped();

    expect(outcome.level, UserLevel.discovery);
    expect(outcome.mistakenLessonIds, isEmpty);
  });
}
