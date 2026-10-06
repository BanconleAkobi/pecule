import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/favorite_dao.dart';
import 'package:pecule/data/repositories/favorites_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late FixedClock clock;
  late FavoritesRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    clock = FixedClock(DateTime.utc(2026, 10, 7, 9));
    repository = FavoritesRepository(
      favorites: FavoriteDao(database),
      clock: clock,
    );
  });
  tearDown(() => database.close());

  test(
    'date chaque ajout avec l\'horloge, pour garder l\'ordre d\'ajout',
    () async {
      await repository.add('bitcoin');
      clock.current = DateTime.utc(2026, 10, 7, 10);
      await repository.add('AAPL');

      expect(await repository.getFavoriteAssetIds(), ['bitcoin', 'AAPL']);
    },
  );

  test('retire un favori', () async {
    await repository.add('bitcoin');

    await repository.remove('bitcoin');

    expect(await repository.getFavoriteAssetIds(), isEmpty);
  });
}
