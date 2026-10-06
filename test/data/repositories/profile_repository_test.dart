import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/user_profile_dao.dart';
import 'package:pecule/data/repositories/profile_repository.dart';
import 'package:pecule/domain/models/quiz_outcome.dart';
import 'package:pecule/domain/models/user_level.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late FixedClock clock;
  late ProfileRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    clock = FixedClock(DateTime.utc(2026, 10, 7, 9));
    repository = ProfileRepository(
      profiles: UserProfileDao(database),
      clock: clock,
    );
  });
  tearDown(() => database.close());

  test('n\'a aucun profil au premier lancement', () async {
    expect(await repository.getProfile(), isNull);
  });

  test(
    'enregistre le résultat du questionnaire comme profil terminé',
    () async {
      await repository.saveQuizOutcome(
        const QuizOutcome(
          correctAnswerCount: 3,
          level: UserLevel.initiated,
          mistakenLessonIds: ['volatilite', 'dca'],
        ),
      );

      final profile = await repository.getProfile();
      expect(profile?.level, UserLevel.initiated);
      expect(profile?.mistakenLessonIds, ['volatilite', 'dca']);
      expect(profile?.onboardingDone, isTrue);
      expect(profile?.createdAt, DateTime.utc(2026, 10, 7, 9));
    },
  );

  test('un questionnaire passé donne un profil Découverte terminé', () async {
    await repository.saveQuizOutcome(const QuizOutcome.skipped());

    final profile = await repository.getProfile();
    expect(profile?.level, UserLevel.discovery);
    expect(profile?.onboardingDone, isTrue);
  });

  test('refaire le questionnaire garde la date du premier profil', () async {
    await repository.saveQuizOutcome(const QuizOutcome.skipped());
    clock.current = DateTime.utc(2026, 11, 2);

    await repository.saveQuizOutcome(
      const QuizOutcome(
        correctAnswerCount: 5,
        level: UserLevel.comfortable,
        mistakenLessonIds: [],
      ),
    );

    final profile = await repository.getProfile();
    expect(profile?.level, UserLevel.comfortable);
    expect(profile?.createdAt, DateTime.utc(2026, 10, 7, 9));
  });
}
