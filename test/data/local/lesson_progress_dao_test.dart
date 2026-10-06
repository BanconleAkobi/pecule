import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/lesson_progress_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late LessonProgressDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = LessonProgressDao(database);
  });
  tearDown(() => database.close());

  test('relit les leçons vues avec leur date', () async {
    await dao.markSeen('volatilite', seenAt: DateTime.utc(2026, 10, 6, 9));

    expect(await dao.findSeenAtByLessonId(), {
      'volatilite': DateTime.utc(2026, 10, 6, 9),
    });
  });

  test('une leçon rouverte garde la date de sa première ouverture', () async {
    await dao.markSeen('volatilite', seenAt: DateTime.utc(2026, 10, 6, 9));

    await dao.markSeen('volatilite', seenAt: DateTime.utc(2026, 10, 7, 9));

    expect(
      (await dao.findSeenAtByLessonId())['volatilite'],
      DateTime.utc(2026, 10, 6, 9),
    );
  });
}
