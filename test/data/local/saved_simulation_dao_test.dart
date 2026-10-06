import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/saved_simulation_dao.dart';
import 'package:pecule/domain/models/dca_plan.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_database.dart';

final monthlyPlan = DcaPlan(
  periodicAmountEur: 50,
  frequency: DcaFrequency.monthly,
  startDate: DateTime.utc(2022, 1, 1),
);

void main() {
  late Database database;
  late SavedSimulationDao dao;

  setUp(() async {
    database = await openTestDatabase();
    dao = SavedSimulationDao(database);
  });
  tearDown(() => database.close());

  test('relit les paramètres d\'une simulation enregistrée', () async {
    final id = await dao.insert(
      assetId: 'bitcoin',
      plan: monthlyPlan,
      createdAt: DateTime.utc(2026, 10, 6, 17, 20),
    );

    final simulation = (await dao.findAll()).single;

    expect(simulation.id, id);
    expect(simulation.assetId, 'bitcoin');
    expect(simulation.plan.periodicAmountEur, 50);
    expect(simulation.plan.frequency, DcaFrequency.monthly);
    expect(simulation.plan.startDate, DateTime.utc(2022, 1, 1));
    expect(simulation.createdAt, DateTime.utc(2026, 10, 6, 17, 20));
  });

  test('relit la simulation la plus récente en premier', () async {
    await dao.insert(
      assetId: 'bitcoin',
      plan: monthlyPlan,
      createdAt: DateTime.utc(2026, 10, 5),
    );
    await dao.insert(
      assetId: 'SPY',
      plan: monthlyPlan,
      createdAt: DateTime.utc(2026, 10, 6),
    );

    final simulations = await dao.findAll();

    expect(simulations.map((simulation) => simulation.assetId), [
      'SPY',
      'bitcoin',
    ]);
  });
}
