import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/local/sql_values.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:sqflite/sqflite.dart';

class PriceBarDao {
  PriceBarDao(this._database);

  static const _table = 'price_bar';

  final Database _database;

  /// Un jour déjà enregistré est remplacé : c'est ainsi que la journée en
  /// cours d'une crypto est réécrite à chaque synchronisation.
  Future<void> saveBars(String assetId, List<PriceBar> bars) async {
    final batch = _database.batch();
    for (final bar in bars) {
      batch.insert(
        _table,
        _toRow(assetId, bar),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PriceBar>> findBars(String assetId) async {
    final rows = await _database.query(
      _table,
      where: 'asset_id = ?',
      whereArgs: [assetId],
      orderBy: 'day ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Map<String, Object?> _toRow(String assetId, PriceBar bar) => {
    'asset_id': assetId,
    'day': formatIsoDay(bar.day),
    'open': bar.open,
    'high': bar.high,
    'low': bar.low,
    'close': bar.close,
    'volume': bar.volume,
    'market_cap': bar.marketCap,
  };

  PriceBar _fromRow(Map<String, Object?> row) => PriceBar(
    day: parseIsoDay(row['day']! as String),
    open: readNullableDouble(row['open']),
    high: readNullableDouble(row['high']),
    low: readNullableDouble(row['low']),
    close: readDouble(row['close']),
    volume: readDouble(row['volume']),
    marketCap: readNullableDouble(row['market_cap']),
  );
}
