import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/paper_transaction_dao.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/paper_transaction.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

PaperTransaction purchaseOf(String assetId, {required DateTime createdAt}) {
  return PaperTransaction(
    assetId: assetId,
    executedOn: DateTime.utc(2026, 1, 2),
    amountEur: 150,
    unitPrice: 243.36,
    priceCurrency: Currency.usd,
    eurUsdRate: 1.0952,
    quantity: 0.675,
    createdAt: createdAt,
  );
}

void main() {
  late Database database;
  late PaperTransactionDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = PaperTransactionDao(database);
  });
  tearDown(() => database.close());

  test('relit un achat avec le cours et le taux figés', () async {
    await dao.insert(
      purchaseOf('AAPL', createdAt: DateTime.utc(2026, 10, 6, 17, 10)),
    );

    final purchase = (await dao.findAll()).single;

    expect(purchase.assetId, 'AAPL');
    expect(purchase.executedOn, DateTime.utc(2026, 1, 2));
    expect(purchase.amountEur, 150);
    expect(purchase.unitPrice, 243.36);
    expect(purchase.priceCurrency, Currency.usd);
    expect(purchase.eurUsdRate, 1.0952);
    expect(purchase.quantity, 0.675);
    expect(purchase.createdAt, DateTime.utc(2026, 10, 6, 17, 10));
  });

  test('relit les achats dans l\'ordre où ils ont été faits', () async {
    await dao.insert(
      purchaseOf('SPY', createdAt: DateTime.utc(2026, 10, 6, 12)),
    );
    await dao.insert(
      purchaseOf('AAPL', createdAt: DateTime.utc(2026, 10, 6, 9)),
    );

    final purchases = await dao.findAll();

    expect(purchases.map((purchase) => purchase.assetId), ['AAPL', 'SPY']);
  });

  test('réinitialiser le portefeuille efface tous les achats', () async {
    await dao.insert(purchaseOf('AAPL', createdAt: DateTime.utc(2026, 10, 6)));
    await dao.insert(purchaseOf('SPY', createdAt: DateTime.utc(2026, 10, 6)));

    await dao.deleteAll();

    expect(await dao.findAll(), isEmpty);
  });
}
