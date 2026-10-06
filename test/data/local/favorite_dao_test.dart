import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/favorite_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

DateTime at(int hour) => DateTime.utc(2026, 10, 6, hour);

void main() {
  late Database database;
  late FavoriteDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = FavoriteDao(database);
  });
  tearDown(() => database.close());

  test('relit les favoris dans l\'ordre où ils ont été ajoutés', () async {
    await dao.add('bitcoin', addedAt: at(10));
    await dao.add('AAPL', addedAt: at(9));

    expect(await dao.findAssetIds(), ['AAPL', 'bitcoin']);
  });

  test('ajouter un favori déjà présent ne le duplique pas', () async {
    await dao.add('AAPL', addedAt: at(9));
    await dao.add('bitcoin', addedAt: at(10));

    await dao.add('AAPL', addedAt: at(11));

    expect(await dao.findAssetIds(), ['AAPL', 'bitcoin']);
  });

  test('retire un favori', () async {
    await dao.add('AAPL', addedAt: at(9));

    await dao.remove('AAPL');

    expect(await dao.findAssetIds(), isEmpty);
  });
}
