import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/price_bar_dao.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

DateTime day(int dayOfMonth) => DateTime.utc(2026, 10, dayOfMonth);

PriceBar closeOn(int dayOfMonth, double close) =>
    PriceBar(day: day(dayOfMonth), close: close, volume: 1000);

void main() {
  late Database database;
  late PriceBarDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = PriceBarDao(database);
  });
  tearDown(() => database.close());

  test('relit les cours d\'un actif dans l\'ordre des jours', () async {
    await dao.saveBars('AAPL', [closeOn(5, 3), closeOn(1, 1), closeOn(2, 2)]);

    final bars = await dao.findBars('AAPL');

    expect(bars.map((bar) => bar.day), [day(1), day(2), day(5)]);
  });

  test('remplace le cours d\'un jour déjà enregistré', () async {
    await dao.saveBars('bitcoin', [closeOn(6, 86000)]);

    await dao.saveBars('bitcoin', [closeOn(6, 86253)]);

    final bars = await dao.findBars('bitcoin');
    expect(bars.single.close, 86253);
  });

  test('ne mélange pas les cours de deux actifs', () async {
    await dao.saveBars('AAPL', [closeOn(1, 330)]);
    await dao.saveBars('SPY', [closeOn(1, 570)]);

    final bars = await dao.findBars('SPY');

    expect(bars.single.close, 570);
  });

  test('relit tous les champs d\'un cours d\'action', () async {
    await dao.saveBars('AAPL', [
      PriceBar(
        day: day(1),
        open: 330,
        high: 332.48,
        low: 325.81,
        close: 330.32,
        volume: 36306300,
      ),
    ]);

    final bar = (await dao.findBars('AAPL')).single;

    expect(bar.open, 330);
    expect(bar.high, 332.48);
    expect(bar.low, 325.81);
    expect(bar.close, 330.32);
    expect(bar.volume, 36306300);
    expect(bar.marketCap, isNull);
  });

  test(
    'garde vides l\'ouverture, le plus haut et le plus bas d\'une crypto',
    () async {
      await dao.saveBars('bitcoin', [
        PriceBar(
          day: day(1),
          close: 84841.67,
          volume: 3.3e10,
          marketCap: 1.7e12,
        ),
      ]);

      final bar = (await dao.findBars('bitcoin')).single;

      expect(bar.open, isNull);
      expect(bar.high, isNull);
      expect(bar.low, isNull);
      expect(bar.marketCap, 1.7e12);
    },
  );

  test('ne trouve aucun cours pour un actif jamais téléchargé', () async {
    expect(await dao.findBars('TSLA'), isEmpty);
  });
}
