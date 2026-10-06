import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/lesson_progress_dao.dart';
import 'package:pecule/data/repositories/lesson_progress_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late LessonProgressRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    repository = LessonProgressRepository(
      progress: LessonProgressDao(database),
      clock: FixedClock(DateTime.utc(2026, 10, 7, 9)),
    );
  });
  tearDown(() => database.close());

  test('renvoie l\'ensemble des leçons vues, une fois chacune', () async {
    await repository.markSeen('volatilite');
    await repository.markSeen('dca');
    await repository.markSeen('volatilite');

    expect(await repository.getSeenLessonIds(), {'volatilite', 'dca'});
  });
}
