import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/local/sql_values.dart';
import 'package:pecule/data/local/sync_state.dart';
import 'package:sqflite/sqflite.dart';

class SyncStateDao {
  SyncStateDao(this._database);

  static const _table = 'sync_state';

  final Database _database;

  /// Rien pour une ressource jamais synchronisée.
  Future<SyncState?> find(String resourceKey) async {
    final rows = await _database.query(
      _table,
      where: 'resource_key = ?',
      whereArgs: [resourceKey],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.single);
  }

  Future<void> save(SyncState state) async {
    await _database.insert(
      _table,
      _toRow(state),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _toRow(SyncState state) => {
    'resource_key': state.resourceKey,
    'last_data_day': formatIsoDay(state.lastDataDay),
    'last_fetched_at': toMillis(state.lastFetchedAt),
  };

  SyncState _fromRow(Map<String, Object?> row) => SyncState(
    resourceKey: row['resource_key']! as String,
    lastDataDay: parseIsoDay(row['last_data_day']! as String),
    lastFetchedAt: fromMillis(row['last_fetched_at']),
  );
}
