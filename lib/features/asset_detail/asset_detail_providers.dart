import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/catalogue.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:pecule/features/asset_detail/asset_detail_view.dart';
import 'package:pecule/features/market/market_providers.dart';

/// Historique d'un actif dont la fiche est ouverte : l'utilisateur attend, la
/// demande passe en tête de la file d'attente. Libéré à la fermeture.
final assetHistoryProvider = StreamProvider.autoDispose
    .family<CachedData<List<PriceBar>>, String>(
      (ref, assetId) => ref
          .watch(priceHistoryRepositoryProvider)
          .watchHistory(catalogueById[assetId]!),
    );

typedef AssetDetailKey = ({String assetId, ChartPeriod period});

final assetDetailViewProvider = Provider.autoDispose
    .family<AsyncValue<AssetDetailView>, AssetDetailKey>((ref, key) {
      final history = ref.watch(assetHistoryProvider(key.assetId));
      final rates = ref.watch(eurUsdRatesProvider);

      if (history case AsyncData(value: final history)) {
        if (rates case AsyncData(value: final rates)) {
          return AsyncData(
            buildAssetDetailView(
              asset: catalogueById[key.assetId]!,
              period: key.period,
              history: history,
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
