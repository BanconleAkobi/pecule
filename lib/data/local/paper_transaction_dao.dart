import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/local/sql_values.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/paper_transaction.dart';
import 'package:sqflite/sqflite.dart';

class PaperTransactionDao {
  PaperTransactionDao(this._database);

  static const _table = 'paper_transaction';

  final Database _database;

  Future<void> insert(PaperTransaction transaction) async {
    await _database.insert(_table, _toRow(transaction));
  }

  /// Dans l'ordre où les achats ont été faits.
  Future<List<PaperTransaction>> findAll() async {
    final rows = await _database.query(_table, orderBy: 'created_at ASC');
    return rows.map(_fromRow).toList();
  }

  /// « Réinitialiser le portefeuille » : efface tous les achats fictifs.
  Future<void> deleteAll() async {
    await _database.delete(_table);
  }

  Map<String, Object?> _toRow(PaperTransaction transaction) => {
    'asset_id': transaction.assetId,
    'executed_on': formatIsoDay(transaction.executedOn),
    'amount_eur': transaction.amountEur,
    'unit_price': transaction.unitPrice,
    'price_currency': transaction.priceCurrency.code,
    'eur_usd_rate': transaction.eurUsdRate,
    'quantity': transaction.quantity,
    'created_at': toMillis(transaction.createdAt),
  };

  PaperTransaction _fromRow(Map<String, Object?> row) => PaperTransaction(
    assetId: row['asset_id']! as String,
    executedOn: parseIsoDay(row['executed_on']! as String),
    amountEur: readDouble(row['amount_eur']),
    unitPrice: readDouble(row['unit_price']),
    priceCurrency: Currency.fromCode(row['price_currency']! as String),
    eurUsdRate: readDouble(row['eur_usd_rate']),
    quantity: readDouble(row['quantity']),
    createdAt: fromMillis(row['created_at']),
  );
}
