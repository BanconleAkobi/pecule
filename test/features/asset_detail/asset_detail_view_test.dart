import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/catalogue.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/currency_effect.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:pecule/domain/models/stability_score.dart';
import 'package:pecule/features/asset_detail/asset_detail_view.dart';

import '../../helpers/apple_history.dart';
import '../../helpers/computed_matchers.dart';

final today = DateTime.utc(2026, 10, 7);
final apple = catalogueById['AAPL']!;

AssetDetailView viewOf(
  ChartPeriod period, {
  Asset? asset,
  List<PriceBar>? bars,
}) {
  return buildAssetDetailView(
    asset: asset ?? apple,
    period: period,
    history: CachedData(value: bars ?? appleYear, updatedAt: today),
    eurUsdRates: stableEuro,
    today: today,
  );
}

void main() {
  group('période affichée', () {
    test('garde les cours de la période, en euros', () {
      final view = viewOf(ChartPeriod.oneYear);

      expect(view.points, hasLength(5));
      expect(view.points.first.value, closeTo(100, 1e-9));
      expect(view.points.last.value, closeTo(120, 1e-9));
    });

    test('calcule la variation de la période', () {
      expect(viewOf(ChartPeriod.oneYear).periodChange, isAvailableCloseTo(0.2));
    });

    test(
      'renvoie une variation indisponible avec un seul cours dans le mois',
      () {
        expect(
          viewOf(ChartPeriod.oneMonth).periodChange,
          isUnavailableBecause(UnavailableReason.notEnoughPrices),
        );
      },
    );

    test('garde la variation sur un an, quelle que soit la période', () {
      expect(viewOf(ChartPeriod.oneMonth).yearChange, isAvailableCloseTo(0.2));
    });
  });

  test('donne l\'effet de change de la période', () {
    final effect = viewOf(ChartPeriod.oneYear).currencyEffect;

    expect(
      effect,
      isA<Available<CurrencyEffect>>()
          .having(
            (found) => found.value.performanceUsd,
            'performanceUsd',
            closeTo(0.2, 1e-9),
          )
          .having(
            (found) => found.value.performanceEur,
            'performanceEur',
            closeTo(0.2, 1e-9),
          ),
    );
  });

  test('n\'a pas d\'effet de change pour un actif coté en euros', () {
    const euroAsset = Asset(
      id: 'CW8',
      name: 'MSCI World',
      symbol: 'CW8',
      type: AssetType.etf,
      currency: Currency.eur,
    );

    expect(
      viewOf(ChartPeriod.oneYear, asset: euroAsset).currencyEffect,
      isUnavailableBecause(UnavailableReason.sameCurrency),
    );
  });

  test('calcule le score de stabilité sur un an', () {
    expect(
      viewOf(ChartPeriod.oneMonth).stability,
      isA<Available<StabilityScore>>().having(
        (found) => found.value.level,
        'level',
        StabilityLevel.stable,
      ),
    );
  });

  group('lecture de la courbe', () {
    test('montre le dernier cours tant que le doigt n\'est pas posé', () {
      final reading = readChart(viewOf(ChartPeriod.oneYear))!;

      expect(reading.priceEur, closeTo(120, 1e-9));
      expect(reading.change, isAvailableCloseTo(0.2));
      expect(reading.scrubbedDay, isNull);
    });

    test('montre le cours et la variation au point touché', () {
      final reading = readChart(viewOf(ChartPeriod.oneYear), scrubIndex: 2)!;

      expect(reading.priceEur, closeTo(120 / 1.10, 1e-9));
      expect(reading.change, isAvailableCloseTo(120 / 1.10 / 100 - 1));
      expect(reading.scrubbedDay, DateTime.utc(2026, 4, 1));
    });

    test('ne lit rien sur une période sans cours', () {
      final view = viewOf(ChartPeriod.oneYear, bars: []);

      expect(view.hasPrices, isFalse);
      expect(readChart(view), isNull);
    });
  });
}
