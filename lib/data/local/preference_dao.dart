import 'package:sqflite/sqflite.dart';

class PreferenceDao {
  PreferenceDao(this._database);

  static const _table = 'preference';

  final Database _database;

  /// Rien pour une préférence jamais enregistrée.
  Future<String?> find(String key) async {
    final rows = await _database.query(
      _table,
      where: 'key = ?',
      whereArgs: [key],
    );
    if (rows.isEmpty) return null;
    return rows.single['value']! as String;
  }

  Future<void> save(String key, String value) async {
    await _database.insert(_table, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
