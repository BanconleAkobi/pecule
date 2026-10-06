import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/catalogue.dart';
import 'package:pecule/data/remote/request_throttle.dart';
import 'package:pecule/domain/calculations/price_series.dart';
import 'package:pecule/domain/models/asset_quote.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';

/// Le jour en cours, à minuit UTC.
final todayProvider = Provider<DateTime>((ref) {
  final now = ref.watch(clockProvider).now();
  return DateTime.utc(now.year, now.month, now.day);
});

final eurUsdRatesProvider = StreamProvider<CachedData<List<FxRate>>>(
  (ref) => ref.watch(fxRateRepositoryProvider).watchEurUsdRates(),
);

/// Historique d'un actif téléchargé en arrière-plan, pour l'Explorer : il
/// passe après les demandes de l'utilisateur dans la file d'attente.
final backgroundHistoryProvider =
    StreamProvider.family<CachedData<List<PriceBar>>, String>(
      (ref, assetId) => ref
          .watch(priceHistoryRepositoryProvider)
          .watchHistory(catalogueById[assetId]!, priority: RequestPriority.low),
    );

/// Dernier cours en euros et variation sur un an d'un actif.
final assetQuoteProvider = Provider.family<AsyncValue<AssetQuote>, String>((
  ref,
  assetId,
) {
  final history = ref.watch(backgroundHistoryProvider(assetId));
  final rates = ref.watch(eurUsdRatesProvider);

  if (history case AsyncData(value: final bars)) {
    if (rates case AsyncData(value: final rates)) {
      return AsyncData(
        computeAssetQuote(
          bars.value,
          currency: catalogueById[assetId]!.currency,
          eurUsdRates: rates.value,
          today: ref.watch(todayProvider),
        ),
      );
    }
  }
  if (history case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (rates case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  return const AsyncLoading();
});
