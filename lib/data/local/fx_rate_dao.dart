import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/local/sql_values.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:sqflite/sqflite.dart';

class FxRateDao {
  FxRateDao(this._database);

  static const _table = 'fx_rate';

  final Database _database;

  Future<void> saveRates(List<FxRate> rates) async {
    final batch = _database.batch();
    for (final rate in rates) {
      batch.insert(
        _table,
        _toRow(rate),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<FxRate>> findRates({
    required Currency base,
    required Currency quote,
  }) async {
    final rows = await _database.query(
      _table,
      where: 'base = ? AND quote = ?',
      whereArgs: [base.code, quote.code],
      orderBy: 'day ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Map<String, Object?> _toRow(FxRate rate) => {
    'day': formatIsoDay(rate.day),
    'base': rate.base.code,
    'quote': rate.quote.code,
    'rate': rate.rate,
  };

  FxRate _fromRow(Map<String, Object?> row) => FxRate(
    day: parseIsoDay(row['day']! as String),
    base: Currency.fromCode(row['base']! as String),
    quote: Currency.fromCode(row['quote']! as String),
    rate: readDouble(row['rate']),
  );
}
