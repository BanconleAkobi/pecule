import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/preference_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late PreferenceDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = PreferenceDao(database);
  });
  tearDown(() => database.close());

  test('ne trouve rien pour une préférence jamais enregistrée', () async {
    expect(await dao.find('chart_period'), isNull);
  });

  test('relit la dernière valeur enregistrée', () async {
    await dao.save('chart_period', '1A');

    await dao.save('chart_period', '3A');

    expect(await dao.find('chart_period'), '3A');
  });
}
