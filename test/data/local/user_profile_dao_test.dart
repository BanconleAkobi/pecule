import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/user_profile_dao.dart';
import 'package:pecule/domain/models/user_level.dart';
import 'package:pecule/domain/models/user_profile.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late UserProfileDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = UserProfileDao(database);
  });
  tearDown(() => database.close());

  test('ne trouve aucun profil avant le premier questionnaire', () async {
    expect(await dao.find(), isNull);
  });

  test('relit le niveau, les erreurs et l\'état du questionnaire', () async {
    await dao.save(
      UserProfile(
        level: UserLevel.initiated,
        mistakenLessonIds: const ['volatilite', 'dca'],
        onboardingDone: true,
        createdAt: DateTime.utc(2026, 10, 6, 17, 2),
      ),
    );

    final profile = await dao.find();

    expect(profile?.level, UserLevel.initiated);
    expect(profile?.mistakenLessonIds, ['volatilite', 'dca']);
    expect(profile?.onboardingDone, isTrue);
    expect(profile?.createdAt, DateTime.utc(2026, 10, 6, 17, 2));
  });

  test(
    'refaire le questionnaire remplace le profil, sans en créer un second',
    () async {
      await dao.save(
        UserProfile(
          level: UserLevel.discovery,
          mistakenLessonIds: const [],
          onboardingDone: true,
          createdAt: DateTime.utc(2026, 10, 6),
        ),
      );

      await dao.save(
        UserProfile(
          level: UserLevel.comfortable,
          mistakenLessonIds: const [],
          onboardingDone: true,
          createdAt: DateTime.utc(2026, 10, 6),
        ),
      );

      final rows = await database.query('user_profile');
      expect(rows, hasLength(1));
      expect((await dao.find())?.level, UserLevel.comfortable);
    },
  );
}
