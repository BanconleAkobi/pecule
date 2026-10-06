import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pecule/core/api_keys.dart';
import 'package:pecule/core/clock.dart';
import 'package:pecule/data/local/favorite_dao.dart';
import 'package:pecule/data/local/fx_rate_dao.dart';
import 'package:pecule/data/local/lesson_progress_dao.dart';
import 'package:pecule/data/local/paper_transaction_dao.dart';
import 'package:pecule/data/local/price_bar_dao.dart';
import 'package:pecule/data/local/saved_simulation_dao.dart';
import 'package:pecule/data/local/sync_state_dao.dart';
import 'package:pecule/data/local/user_profile_dao.dart';
import 'package:pecule/data/network_status.dart';
import 'package:pecule/data/remote/coingecko_client.dart';
import 'package:pecule/data/remote/frankfurter_client.dart';
import 'package:pecule/data/remote/price_source.dart';
import 'package:pecule/data/remote/request_throttle.dart';
import 'package:pecule/data/remote/twelve_data_client.dart';
import 'package:pecule/data/repositories/favorites_repository.dart';
import 'package:pecule/data/repositories/fx_rate_repository.dart';
import 'package:pecule/data/repositories/incremental_sync.dart';
import 'package:pecule/data/repositories/lesson_progress_repository.dart';
import 'package:pecule/data/repositories/portfolio_repository.dart';
import 'package:pecule/data/repositories/price_history_repository.dart';
import 'package:pecule/data/repositories/profile_repository.dart';
import 'package:pecule/data/repositories/simulation_repository.dart';
import 'package:sqflite/sqflite.dart';

// Le seul endroit qui sait construire les objets de l'application. Les écrans
// et leurs providers ne font que les demander, et les tests peuvent remplacer
// n'importe lequel par une doublure.

final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Ouverte dans `main` avant le premier écran, puis fournie par une
/// surcharge du `ProviderScope`.
final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('La base est ouverte dans main().'),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final networkStatusProvider = Provider<NetworkStatus>((ref) {
  final status = NetworkStatus();
  ref.onDispose(status.dispose);
  return status;
});

/// Vrai quand le dernier appel réseau a échoué faute de connexion.
final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final status = ref.watch(networkStatusProvider);
  yield status.isOffline;
  yield* status.offlineChanges;
});

final twelveDataClientProvider = Provider<TwelveDataClient>(
  (ref) => TwelveDataClient(ref.watch(httpClientProvider), ApiKeys.twelveData),
);

final coinGeckoClientProvider = Provider<CoinGeckoClient>(
  (ref) => CoinGeckoClient(ref.watch(httpClientProvider), ApiKeys.coinGecko),
);

final frankfurterClientProvider = Provider<FrankfurterClient>(
  (ref) => FrankfurterClient(ref.watch(httpClientProvider)),
);

// Quota du plan gratuit de Twelve Data (cahier des charges, section 5.3).
final twelveDataThrottleProvider = Provider<RequestThrottle>(
  (ref) => RequestThrottle(
    maxRequests: 8,
    window: const Duration(minutes: 1),
    clock: ref.watch(clockProvider),
  ),
);

final priceSourceProvider = Provider<PriceSource>(
  (ref) => RemotePriceSource(
    twelveData: ref.watch(twelveDataClientProvider),
    twelveDataThrottle: ref.watch(twelveDataThrottleProvider),
    coinGecko: ref.watch(coinGeckoClientProvider),
    clock: ref.watch(clockProvider),
  ),
);

final incrementalSyncProvider = Provider<IncrementalSync>(
  (ref) => IncrementalSync(
    syncStates: SyncStateDao(ref.watch(databaseProvider)),
    clock: ref.watch(clockProvider),
    networkStatus: ref.watch(networkStatusProvider),
  ),
);

final priceHistoryRepositoryProvider = Provider<PriceHistoryRepository>(
  (ref) => PriceHistoryRepository(
    priceBars: PriceBarDao(ref.watch(databaseProvider)),
    source: ref.watch(priceSourceProvider),
    sync: ref.watch(incrementalSyncProvider),
  ),
);

final fxRateRepositoryProvider = Provider<FxRateRepository>(
  (ref) => FxRateRepository(
    fxRates: FxRateDao(ref.watch(databaseProvider)),
    frankfurter: ref.watch(frankfurterClientProvider),
    sync: ref.watch(incrementalSyncProvider),
  ),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(
    favorites: FavoriteDao(ref.watch(databaseProvider)),
    clock: ref.watch(clockProvider),
  ),
);

final portfolioRepositoryProvider = Provider<PortfolioRepository>(
  (ref) => PortfolioRepository(
    transactions: PaperTransactionDao(ref.watch(databaseProvider)),
  ),
);

final simulationRepositoryProvider = Provider<SimulationRepository>(
  (ref) => SimulationRepository(
    simulations: SavedSimulationDao(ref.watch(databaseProvider)),
    clock: ref.watch(clockProvider),
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    profiles: UserProfileDao(ref.watch(databaseProvider)),
    clock: ref.watch(clockProvider),
  ),
);

final lessonProgressRepositoryProvider = Provider<LessonProgressRepository>(
  (ref) => LessonProgressRepository(
    progress: LessonProgressDao(ref.watch(databaseProvider)),
    clock: ref.watch(clockProvider),
  ),
);
