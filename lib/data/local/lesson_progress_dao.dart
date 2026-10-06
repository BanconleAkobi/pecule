import 'package:pecule/data/local/sql_values.dart';
import 'package:sqflite/sqflite.dart';

class LessonProgressDao {
  LessonProgressDao(this._database);

  static const _table = 'lesson_progress';

  final Database _database;

  /// Une leçon rouverte garde la date de sa première ouverture.
  Future<void> markSeen(String lessonId, {required DateTime seenAt}) async {
    await _database.insert(_table, {
      'lesson_id': lessonId,
      'seen_at': toMillis(seenAt),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, DateTime>> findSeenAtByLessonId() async {
    final rows = await _database.query(_table);
    return {
      for (final row in rows)
        row['lesson_id']! as String: fromMillis(row['seen_at']),
    };
  }
}
