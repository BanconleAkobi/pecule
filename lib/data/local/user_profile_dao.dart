import 'dart:convert';

import 'package:pecule/data/local/sql_values.dart';
import 'package:pecule/domain/models/user_level.dart';
import 'package:pecule/domain/models/user_profile.dart';
import 'package:sqflite/sqflite.dart';

class UserProfileDao {
  UserProfileDao(this._database);

  static const _table = 'user_profile';

  // Pécule n'a pas de comptes : la table ne contient jamais qu'une ligne.
  static const _singleProfileId = 1;

  final Database _database;

  /// Rien avant la fin du premier questionnaire.
  Future<UserProfile?> find() async {
    final rows = await _database.query(
      _table,
      where: 'id = ?',
      whereArgs: [_singleProfileId],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.single);
  }

  /// Remplace le profil existant, par exemple quand le questionnaire est refait.
  Future<void> save(UserProfile profile) async {
    await _database.insert(
      _table,
      _toRow(profile),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _toRow(UserProfile profile) => {
    'id': _singleProfileId,
    'level': profile.level.name,
    'quiz_mistakes': jsonEncode(profile.mistakenLessonIds),
    'onboarding_done': profile.onboardingDone ? 1 : 0,
    'created_at': toMillis(profile.createdAt),
  };

  UserProfile _fromRow(Map<String, Object?> row) => UserProfile(
    level: UserLevel.values.byName(row['level']! as String),
    mistakenLessonIds: [
      for (final lessonId
          in jsonDecode(row['quiz_mistakes']! as String) as List<dynamic>)
        lessonId as String,
    ],
    onboardingDone: row['onboarding_done'] == 1,
    createdAt: fromMillis(row['created_at']),
  );
}
