import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pecule/data/local/fx_rate_dao.dart';
import 'package:pecule/data/local/sync_state.dart';
import 'package:pecule/data/local/sync_state_dao.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/data/remote/dto/frankfurter_dto.dart';
import 'package:pecule/data/remote/frankfurter_client.dart';
import 'package:pecule/data/repositories/fx_rate_repository.dart';
import 'package:pecule/data/repositories/incremental_sync.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

class MockFrankfurterClient extends Mock implements FrankfurterClient {}

DateTime october(int day, [int hour = 0]) => DateTime.utc(2026, 10, day, hour);

FrankfurterRateDto rateDto(DateTime day, double rate) =>
    FrankfurterRateDto(day: day, base: 'EUR', quote: 'USD', rate: rate);

void main() {
  late Database database;
  late FxRateDao fxRates;
  late SyncStateDao syncStates;
  late MockFrankfurterClient frankfurter;
  late FixedClock clock;
  late FxRateRepository repository;

  setUpAll(() => registerFallbackValue(DateTime.utc(2000)));

  setUp(() async {
    database = await openTestDatabase();
    fxRates = FxRateDao(database);
    syncStates = SyncStateDao(database);
    frankfurter = MockFrankfurterClient();
    // Mercredi 7 octobre 2026 à 17 h UTC : le taux du jour est publié.
    clock = FixedClock(october(7, 17));
    repository = FxRateRepository(
      fxRates: fxRates,
      frankfurter: frankfurter,
      sync: IncrementalSync(syncStates: syncStates, clock: clock),
    );
  });
  tearDown(() => database.close());

  void answerWith(List<FrankfurterRateDto> rates) {
    when(() => frankfurter.fetchEurUsdRates(from: any(named: 'from')))
        .thenAnswer((_) async => rates);
  }

  Future<void> seedRate(DateTime day, {required DateTime lastFetchedAt}) async {
    await fxRates.saveRates([
      FxRate(day: day, base: Currency.eur, quote: Currency.usd, rate: 1.13),
    ]);
    await syncStates.save(
      SyncState(
        resourceKey: 'fx:EUR:USD',
        lastDataDay: day,
        lastFetchedAt: lastFetchedAt,
      ),
    );
  }

  DateTime requestedFrom() =>
      verify(
            () => frankfurter.fetchEurUsdRates(from: captureAny(named: 'from')),
          ).captured.single
          as DateTime;

  test(
    'premier chargement : télécharge les taux depuis 2020 et les convertit',
    () async {
      answerWith([rateDto(october(6), 1.1238), rateDto(october(7), 1.1229)]);

      final emitted = await repository.watchEurUsdRates().toList();

      expect(requestedFrom(), DateTime.utc(2020, 1, 1));
      final rates = emitted.single.value;
      expect(rates.map((rate) => rate.rate), [1.1238, 1.1229]);
      expect(rates.first.base, Currency.eur);
      expect(rates.first.quote, Currency.usd);
    },
  );

  test('ne demande que les jours qui manquent', () async {
    await seedRate(october(5), lastFetchedAt: october(6, 9));
    answerWith([rateDto(october(6), 1.1238), rateDto(october(7), 1.1229)]);

    final emitted = await repository.watchEurUsdRates().toList();

    expect(requestedFrom(), october(6));
    expect(emitted.last.value, hasLength(3));
  });

  test(
    'avant 16 h UTC, ne redemande pas un taux de la veille déjà en base',
    () async {
      clock.current = october(7, 10);
      await seedRate(october(6), lastFetchedAt: october(6, 17));

      await repository.watchEurUsdRates().toList();

      verifyNever(() => frankfurter.fetchEurUsdRates(from: any(named: 'from')));
    },
  );

  test(
    'garde les taux en cache et signale l\'erreur si le réseau échoue',
    () async {
      await seedRate(october(5), lastFetchedAt: october(6, 9));
      when(() => frankfurter.fetchEurUsdRates(from: any(named: 'from')))
          .thenThrow(const NetworkException('hors ligne'));

      final emitted = await repository.watchEurUsdRates().toList();

      expect(emitted.last.value, hasLength(1));
      expect(emitted.last.refreshError, isA<NetworkException>());
    },
  );
}
