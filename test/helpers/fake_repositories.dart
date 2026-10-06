import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:pecule/app/theme/pecule_theme.dart';
import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/remote/request_throttle.dart';
import 'package:pecule/data/repositories/favorites_repository.dart';
import 'package:pecule/data/repositories/fx_rate_repository.dart';
import 'package:pecule/data/repositories/price_history_repository.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';

import 'fixed_clock.dart';

/// Mercredi 7 octobre 2026 à 23 h UTC, l'heure de référence des écrans testés.
final testNow = DateTime.utc(2026, 10, 7, 23);

class FakePriceHistoryRepository implements PriceHistoryRepository {
  FakePriceHistoryRepository([this.barsByAssetId = const {}]);

  final Map<String, List<PriceBar>> barsByAssetId;

  @override
  Stream<CachedData<List<PriceBar>>> watchHistory(
    Asset asset, {
    bool forceRefresh = false,
    RequestPriority priority = RequestPriority.high,
  }) {
    return Stream.value(
      CachedData(
        value: barsByAssetId[asset.id] ?? const [],
        updatedAt: testNow,
      ),
    );
  }
}

class FakeFxRateRepository implements FxRateRepository {
  FakeFxRateRepository([this.rates = const []]);

  final List<FxRate> rates;

  @override
  Stream<CachedData<List<FxRate>>> watchEurUsdRates({
    bool forceRefresh = false,
  }) {
    return Stream.value(CachedData(value: rates, updatedAt: testNow));
  }
}

class FakeFavoritesRepository implements FavoritesRepository {
  final assetIds = <String>[];

  @override
  Future<List<String>> getFavoriteAssetIds() async => [...assetIds];

  @override
  Future<void> add(String assetId) async => assetIds.add(assetId);

  @override
  Future<void> remove(String assetId) async => assetIds.remove(assetId);
}

/// Remplace la base et le réseau par des doublures : les écrans s'affichent
/// sans téléphone ni connexion.
List<Override> fakeAppOverrides({
  PriceHistoryRepository? prices,
  FxRateRepository? rates,
  FavoritesRepository? favorites,
  bool isOffline = false,
}) {
  return [
    priceHistoryRepositoryProvider.overrideWithValue(
      prices ?? FakePriceHistoryRepository(),
    ),
    fxRateRepositoryProvider.overrideWithValue(rates ?? FakeFxRateRepository()),
    favoritesRepositoryProvider.overrideWithValue(
      favorites ?? FakeFavoritesRepository(),
    ),
    clockProvider.overrideWithValue(FixedClock(testNow)),
    isOfflineProvider.overrideWith((ref) => Stream.value(isOffline)),
  ];
}

/// Affiche [child] dans l'application, avec les doublures.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: overrides.isEmpty ? fakeAppOverrides() : overrides,
      child: MaterialApp(
        theme: buildPeculeTheme(),
        home: Scaffold(body: child),
      ),
    ),
  );
}
