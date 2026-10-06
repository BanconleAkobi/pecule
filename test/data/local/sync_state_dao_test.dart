import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/sync_state.dart';
import 'package:pecule/data/local/sync_state_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late SyncStateDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = SyncStateDao(database);
  });
  tearDown(() => database.close());

  test('ne trouve rien pour une ressource jamais synchronisée', () async {
    expect(await dao.find('asset:AAPL'), isNull);
  });

  test('relit le dernier jour reçu et l\'heure du dernier appel', () async {
    await dao.save(
      SyncState(
        resourceKey: 'asset:AAPL',
        lastDataDay: DateTime.utc(2026, 10, 1),
        lastFetchedAt: DateTime.utc(2026, 10, 6, 16, 2, 30),
      ),
    );

    final state = await dao.find('asset:AAPL');

    expect(state?.lastDataDay, DateTime.utc(2026, 10, 1));
    expect(state?.lastFetchedAt, DateTime.utc(2026, 10, 6, 16, 2, 30));
  });

  test('remplace l\'état précédent d\'une ressource', () async {
    final first = DateTime.utc(2026, 10, 1);
    final second = DateTime.utc(2026, 10, 2);
    await dao.save(
      SyncState(
        resourceKey: 'fx:EUR:USD',
        lastDataDay: first,
        lastFetchedAt: first,
      ),
    );

    await dao.save(
      SyncState(
        resourceKey: 'fx:EUR:USD',
        lastDataDay: second,
        lastFetchedAt: second,
      ),
    );

    expect((await dao.find('fx:EUR:USD'))?.lastDataDay, second);
  });
}
