import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/local/price_bar_dao.dart';
import 'package:pecule/data/local/sync_state.dart';
import 'package:pecule/data/local/sync_state_dao.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/data/remote/price_source.dart';
import 'package:pecule/data/remote/request_throttle.dart';
import 'package:pecule/data/repositories/incremental_sync.dart';
import 'package:pecule/data/repositories/price_history_repository.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_assets.dart';
import '../../helpers/test_database.dart';

class MockPriceSource extends Mock implements PriceSource {}

// Mercredi 7 octobre 2026 à 23 h UTC : le cours du jour d'une action est
// déjà publié.
final now = DateTime.utc(2026, 10, 7, 23);

DateTime october(int day, [int hour = 0]) => DateTime.utc(2026, 10, day, hour);

PriceBar closeOn(DateTime day, double close) =>
    PriceBar(day: day, close: close, volume: 1000);

void main() {
  late Database database;
  late PriceBarDao priceBars;
  late SyncStateDao syncStates;
  late MockPriceSource source;
  late PriceHistoryRepository repository;

  setUpAll(() {
    registerFallbackValue(apple);
    registerFallbackValue(DateTime.utc(2000));
    registerFallbackValue(RequestPriority.high);
  });

  setUp(() async {
    database = await openTestDatabase();
    priceBars = PriceBarDao(database);
    syncStates = SyncStateDao(database);
    source = MockPriceSource();
    repository = PriceHistoryRepository(
      priceBars: priceBars,
      source: source,
      sync: IncrementalSync(syncStates: syncStates, clock: FixedClock(now)),
    );
  });
  tearDown(() => database.close());

  // N'importe quel appel à la source, quels que soient l'actif, le jour de
  // départ et la priorité.
  Future<List<PriceBar>> anyFetch() => source.fetchDailyBars(
    any(),
    since: any(named: 'since'),
    priority: any(named: 'priority'),
  );

  void answerWith(List<PriceBar> bars) {
    when(anyFetch).thenAnswer((_) async => bars);
  }

  void failWith(ApiException error) {
    when(anyFetch).thenThrow(error);
  }

  Future<void> seedCache(
    Asset asset, {
    required List<PriceBar> bars,
    required DateTime lastFetchedAt,
  }) async {
    await priceBars.saveBars(asset.id, bars);
    await syncStates.save(
      SyncState(
        resourceKey: 'asset:${asset.id}',
        lastDataDay: bars.last.day,
        lastFetchedAt: lastFetchedAt,
      ),
    );
  }

  Future<List<CachedData<List<PriceBar>>>> watch(
    Asset asset, {
    bool forceRefresh = false,
  }) => repository.watchHistory(asset, forceRefresh: forceRefresh).toList();

  DateTime requestedSince() =>
      verify(
            () => source.fetchDailyBars(
              any(),
              since: captureAny(named: 'since'),
              priority: any(named: 'priority'),
            ),
          ).captured.single
          as DateTime;

  group('premier chargement', () {
    test(
      'télécharge l\'historique d\'une action depuis 2020 et l\'enregistre',
      () async {
        answerWith([closeOn(october(6), 330), closeOn(october(7), 332)]);

        final emitted = await watch(apple);

        expect(requestedSince(), DateTime.utc(2020, 1, 1));
        expect(emitted.single.value, hasLength(2));
        expect(emitted.single.updatedAt, now);
        expect(await priceBars.findBars('AAPL'), hasLength(2));
      },
    );

    test(
      'télécharge les 364 derniers jours d\'une crypto, limite du plan Demo',
      () async {
        answerWith([closeOn(october(7), 86000)]);

        await watch(bitcoin);

        expect(requestedSince(), DateTime.utc(2025, 10, 8));
      },
    );

    test('transmet à la source la priorité basse de l\'Explorer', () async {
      answerWith([closeOn(october(7), 332)]);

      await repository
          .watchHistory(apple, priority: RequestPriority.low)
          .toList();

      final priority = verify(
        () => source.fetchDailyBars(
          any(),
          since: any(named: 'since'),
          priority: captureAny(named: 'priority'),
        ),
      ).captured.single;
      expect(priority, RequestPriority.low);
    });
  });

  group('cache à compléter', () {
    test('émet tout de suite le cache, puis l\'historique complété', () async {
      await seedCache(
        apple,
        bars: [closeOn(october(1), 330)],
        lastFetchedAt: october(2, 10),
      );
      answerWith([closeOn(october(2), 331), closeOn(october(7), 332)]);

      final emitted = await watch(apple);

      expect(emitted, hasLength(2));
      expect(emitted.first.value, hasLength(1));
      expect(emitted.first.updatedAt, october(2, 10));
      expect(emitted.last.value, hasLength(3));
      expect(emitted.last.updatedAt, now);
    });

    test('ne demande que les jours qui manquent', () async {
      await seedCache(
        apple,
        bars: [closeOn(october(1), 330)],
        lastFetchedAt: october(2, 10),
      );
      answerWith([]);

      await watch(apple);

      expect(requestedSince(), october(2));
    });

    test(
      'redemande le dernier jour d\'une crypto, dont le cours bougeait encore',
      () async {
        await seedCache(
          bitcoin,
          bars: [closeOn(october(6), 86000)],
          lastFetchedAt: october(6, 12),
        );
        answerWith([closeOn(october(6), 86253), closeOn(october(7), 87000)]);

        final emitted = await watch(bitcoin);

        expect(requestedSince(), october(6));
        expect(emitted.last.value.first.close, 86253);
      },
    );

    test(
      'rien de nouveau : garde le dernier jour et note l\'heure de l\'appel',
      () async {
        await seedCache(
          apple,
          bars: [closeOn(october(6), 330)],
          lastFetchedAt: october(7, 10),
        );
        answerWith([]);

        await watch(apple);

        final syncState = await syncStates.find('asset:AAPL');
        expect(syncState?.lastDataDay, october(6));
        expect(syncState?.lastFetchedAt, now);
      },
    );
  });

  group('appels évités', () {
    test('n\'appelle pas l\'API si la dernière actualisation a moins de six heures', () async {
      await seedCache(
        apple,
        bars: [closeOn(october(6), 330)],
        lastFetchedAt: now.subtract(const Duration(hours: 2)),
      );

      final emitted = await watch(apple);

      verifyNever(anyFetch);
      expect(emitted.single.value, hasLength(1));
    });

    test('tirer pour actualiser ignore le délai de six heures', () async {
      await seedCache(
        apple,
        bars: [closeOn(october(6), 330)],
        lastFetchedAt: now.subtract(const Duration(hours: 2)),
      );
      answerWith([closeOn(october(7), 332)]);

      await watch(apple, forceRefresh: true);

      expect(requestedSince(), october(7));
    });

    test(
      'n\'appelle pas l\'API si le dernier jour attendu est déjà en base',
      () async {
        await seedCache(
          apple,
          bars: [closeOn(october(7), 332)],
          lastFetchedAt: october(7, 10),
        );

        final emitted = await watch(apple);

        verifyNever(anyFetch);
        expect(emitted.last.updatedAt, now);
        expect((await syncStates.find('asset:AAPL'))?.lastFetchedAt, now);
      },
    );
  });

  group('échec du réseau', () {
    test('garde les cours en cache et signale l\'erreur', () async {
      await seedCache(
        apple,
        bars: [closeOn(october(1), 330)],
        lastFetchedAt: october(2, 10),
      );
      failWith(const NetworkException('hors ligne'));

      final emitted = await watch(apple);

      expect(emitted.last.value, hasLength(1));
      expect(emitted.last.updatedAt, october(2, 10));
      expect(emitted.last.refreshError, isA<NetworkException>());
      expect(emitted.last.isStale, isTrue);
    });

    test(
      'sans cache, renvoie un historique vide avec l\'erreur, sans planter',
      () async {
        failWith(const RateLimitException('quota atteint'));

        final emitted = await watch(apple);

        expect(emitted.single.value, isEmpty);
        expect(emitted.single.updatedAt, isNull);
        expect(emitted.single.refreshError, isA<RateLimitException>());
      },
    );
  });
}
