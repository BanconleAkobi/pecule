import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/fx_rate_dao.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

DateTime day(int dayOfMonth) => DateTime.utc(2026, 10, dayOfMonth);

FxRate eurUsd(int dayOfMonth, double rate) => FxRate(
  day: day(dayOfMonth),
  base: Currency.eur,
  quote: Currency.usd,
  rate: rate,
);

void main() {
  late Database database;
  late FxRateDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = FxRateDao(database);
  });
  tearDown(() => database.close());

  Future<List<FxRate>> findEurUsd() =>
      dao.findRates(base: Currency.eur, quote: Currency.usd);

  test('relit les taux dans l\'ordre des jours', () async {
    await dao.saveRates([eurUsd(6, 1.1229), eurUsd(1, 1.1327)]);

    final rates = await findEurUsd();

    expect(rates.map((rate) => rate.day), [day(1), day(6)]);
    expect(rates.first.rate, 1.1327);
  });

  test('remplace le taux d\'un jour déjà enregistré', () async {
    await dao.saveRates([eurUsd(6, 1.12)]);

    await dao.saveRates([eurUsd(6, 1.1229)]);

    expect((await findEurUsd()).single.rate, 1.1229);
  });

  test('ne renvoie que la paire de devises demandée', () async {
    await dao.saveRates([
      eurUsd(1, 1.1327),
      FxRate(day: day(1), base: Currency.usd, quote: Currency.eur, rate: 0.88),
    ]);

    final rates = await findEurUsd();

    expect(rates.single.base, Currency.eur);
    expect(rates.single.quote, Currency.usd);
  });
}
