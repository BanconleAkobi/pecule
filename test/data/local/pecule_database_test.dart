import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/fx_rate_dao.dart';
import 'package:pecule/data/local/pecule_database.dart';
import 'package:pecule/data/local/price_bar_dao.dart';
import 'package:pecule/data/local/sync_state.dart';
import 'package:pecule/data/local/sync_state_dao.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database database;

  setUp(() async => database = await openTestDatabase());
  tearDown(() => database.close());

  Future<int> countRows(String table) async {
    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM $table',
    );
    return rows.single['count']! as int;
  }

  test('crée les neuf tables du MCD', () async {
    final rows = await database.query(
      'sqlite_master',
      columns: ['name'],
      where: "type = 'table' AND name NOT LIKE 'sqlite_%'",
    );

    expect(
      rows.map((row) => row['name']),
      unorderedEquals([
        'user_profile',
        'preference',
        'lesson_progress',
        'favorite',
        'paper_transaction',
        'saved_simulation',
        'price_bar',
        'fx_rate',
        'sync_state',
      ]),
    );
  });

  test(
    'vider le cache efface les cours, les taux et la synchronisation',
    () async {
      final day = DateTime.utc(2026, 10, 1);
      await PriceBarDao(
        database,
      ).saveBars('AAPL', [PriceBar(day: day, close: 330.32, volume: 36306300)]);
      await FxRateDao(database).saveRates([
        FxRate(day: day, base: Currency.eur, quote: Currency.usd, rate: 1.1327),
      ]);
      await SyncStateDao(database).save(
        SyncState(
          resourceKey: 'asset:AAPL',
          lastDataDay: day,
          lastFetchedAt: day,
        ),
      );

      await clearCache(database);

      expect(await countRows('price_bar'), 0);
      expect(await countRows('fx_rate'), 0);
      expect(await countRows('sync_state'), 0);
    },
  );

  test('vider le cache garde les données de l\'utilisateur', () async {
    await database.insert('favorite', {'asset_id': 'AAPL', 'added_at': 0});

    await clearCache(database);

    expect(await countRows('favorite'), 1);
  });
}
