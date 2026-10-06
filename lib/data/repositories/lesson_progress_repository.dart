import 'package:pecule/core/clock.dart';
import 'package:pecule/data/local/lesson_progress_dao.dart';

class LessonProgressRepository {
  LessonProgressRepository({required this._progress, required this._clock});

  final LessonProgressDao _progress;
  final Clock _clock;

  Future<Set<String>> getSeenLessonIds() async =>
      (await _progress.findSeenAtByLessonId()).keys.toSet();

  Future<void> markSeen(String lessonId) =>
      _progress.markSeen(lessonId, seenAt: _clock.now());
}
