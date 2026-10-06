import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/price_series.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/currency_effect.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:pecule/domain/models/price_point.dart';

import '../../helpers/computed_matchers.dart';

DateTime day(int month, int dayOfMonth) =>
    DateTime.utc(2026, month, dayOfMonth);

PriceBar closeOn(DateTime day, double close) =>
    PriceBar(day: day, close: close, volume: 0);

FxRate eurUsd(DateTime day, double rate) =>
    FxRate(day: day, base: Currency.eur, quote: Currency.usd, rate: rate);

PricePoint point(DateTime day, double value) =>
    PricePoint(day: day, value: value);

void main() {
  group('conversion en euros', () {
    test('convertit chaque cours au taux de son propre jour', () {
      final points = closesInEur(
        [closeOn(day(10, 1), 110), closeOn(day(10, 2), 120)],
        currency: Currency.usd,
        eurUsdRates: [eurUsd(day(10, 1), 1.10), eurUsd(day(10, 2), 1.20)],
      );

      expect(points.map((point) => point.value), [
        closeTo(100, 1e-9),
        closeTo(100, 1e-9),
      ]);
    });

    test('prend le dernier taux connu pour un jour sans taux', () {
      final points = closesInEur(
        [closeOn(day(10, 5), 110)],
        currency: Currency.usd,
        eurUsdRates: [eurUsd(day(10, 2), 1.10)],
      );

      expect(points.single.value, closeTo(100, 1e-9));
    });

    test('écarte les cours antérieurs au premier taux connu', () {
      final points = closesInEur(
        [closeOn(day(1, 1), 100), closeOn(day(1, 2), 110)],
        currency: Currency.usd,
        eurUsdRates: [eurUsd(day(1, 2), 1.10)],
      );

      expect(points.map((point) => point.day), [day(1, 2)]);
    });

    test('laisse tels quels les cours d\'un actif coté en euros', () {
      final points = closesInEur(
        [closeOn(day(10, 1), 42)],
        currency: Currency.eur,
        eurUsdRates: [],
      );

      expect(points.single.value, 42);
    });
  });

  group('période', () {
    final today = day(10, 7);
    final points = [
      point(DateTime.utc(2025, 6, 1), 1),
      point(day(9, 6), 2),
      point(day(9, 7), 3),
      point(day(10, 7), 4),
    ];

    List<PricePoint> pointsIn(ChartPeriod period) => itemsInPeriod(
      points,
      period,
      today: today,
      dayOf: (point) => point.day,
    );

    test('garde les points du dernier mois, premier jour compris', () {
      expect(pointsIn(ChartPeriod.oneMonth).map((point) => point.value), [
        3,
        4,
      ]);
    });

    test('garde tout l\'historique pour « Max »', () {
      expect(pointsIn(ChartPeriod.max), hasLength(4));
    });
  });

  group('variation sur la période', () {
    test('compare le premier et le dernier point', () {
      final change = computeSeriesChange([
        point(day(10, 1), 100),
        point(day(10, 4), 90),
        point(day(10, 7), 118),
      ]);

      expect(change, isAvailableCloseTo(0.18));
    });

    test('renvoie indisponible avec moins de deux points', () {
      expect(
        computeSeriesChange([point(day(10, 1), 100)]),
        isUnavailableBecause(UnavailableReason.notEnoughPrices),
      );
    });
  });

  group('effet de change sur la période', () {
    test('retrouve l\'exemple du cahier sur un historique en dollars', () {
      final effect = computeCurrencyEffectOverBars(
        [closeOn(day(1, 2), 100), closeOn(day(10, 1), 118)],
        eurUsdRates: [eurUsd(day(1, 2), 1.05), eurUsd(day(10, 1), 1.10)],
      );

      expect(
        effect,
        isA<Available<CurrencyEffect>>().having(
          (found) => found.value.performanceEur,
          'performanceEur',
          closeTo(0.1264, 1e-4),
        ),
      );
    });

    test('renvoie indisponible sans taux au début de la période', () {
      final effect = computeCurrencyEffectOverBars(
        [closeOn(day(1, 2), 100), closeOn(day(10, 1), 118)],
        eurUsdRates: [eurUsd(day(10, 1), 1.10)],
      );

      expect(effect, isUnavailableBecause(UnavailableReason.noDataForDate));
    });
  });
}
