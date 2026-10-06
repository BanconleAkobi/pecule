import 'package:pecule/data/local/sql_values.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteDao {
  FavoriteDao(this._database);

  static const _table = 'favorite';

  final Database _database;

  /// Un actif déjà en favori garde sa date de premier ajout.
  Future<void> add(String assetId, {required DateTime addedAt}) async {
    await _database.insert(_table, {
      'asset_id': assetId,
      'added_at': toMillis(addedAt),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> remove(String assetId) async {
    await _database.delete(_table, where: 'asset_id = ?', whereArgs: [assetId]);
  }

  /// Dans l'ordre d'ajout.
  Future<List<String>> findAssetIds() async {
    final rows = await _database.query(_table, orderBy: 'added_at ASC');
    return [for (final row in rows) row['asset_id']! as String];
  }
}
