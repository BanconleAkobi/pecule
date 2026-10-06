import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/local/saved_simulation_dao.dart';
import 'package:pecule/data/repositories/simulation_repository.dart';
import 'package:pecule/domain/models/dca_plan.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

void main() {
  late Database database;
  late SimulationRepository repository;

  setUp(() async {
    database = await openTestDatabase();
    repository = SimulationRepository(
      simulations: SavedSimulationDao(database),
      clock: FixedClock(DateTime.utc(2026, 10, 7, 17, 20)),
    );
  });
  tearDown(() => database.close());

  test('date l\'enregistrement avec l\'horloge', () async {
    final id = await repository.save(
      assetId: 'bitcoin',
      plan: DcaPlan(
        periodicAmountEur: 50,
        frequency: DcaFrequency.monthly,
        startDate: DateTime.utc(2025, 11, 1),
      ),
    );

    final saved = (await repository.getSavedSimulations()).single;
    expect(saved.id, id);
    expect(saved.createdAt, DateTime.utc(2026, 10, 7, 17, 20));
  });
}
