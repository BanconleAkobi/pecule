import 'package:pecule/domain/calculations/currency.dart';
import 'package:pecule/domain/calculations/dated_lookup.dart';
import 'package:pecule/domain/calculations/variation.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/currency_effect.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:pecule/domain/models/price_point.dart';

/// Historique converti en euros, chaque cours au taux de son propre jour. Les
/// tout premiers cours, antérieurs au premier taux connu, sont écartés.
/// [eurUsdRates] est trié par jour croissant.
List<PricePoint> closesInEur(
  List<PriceBar> bars, {
  required Currency currency,
  required List<FxRate> eurUsdRates,
}) {
  final points = <PricePoint>[];
  for (final bar in bars) {
    if (currency == Currency.eur) {
      points.add(PricePoint(day: bar.day, value: bar.close));
      continue;
    }
    final rate = findLastOnOrBefore(
      eurUsdRates,
      bar.day,
      dayOf: (rate) => rate.day,
    );
    if (rate case Available(value: final rate)) {
      final valueEur = convertToEur(
        bar.close,
        from: currency,
        eurUsdRate: rate.rate,
      );
      points.add(PricePoint(day: bar.day, value: valueEur));
    }
  }
  return points;
}

/// Éléments de [series] compris dans [period], jusqu'à [today].
List<T> itemsInPeriod<T>(
  List<T> series,
  ChartPeriod period, {
  required DateTime today,
  required DateTime Function(T item) dayOf,
}) {
  final start = period.startDay(today);
  if (start == null) return series;
  return series.where((item) => !dayOf(item).isBefore(start)).toList();
}

/// Variation entre le premier et le dernier point : +0,18 pour une hausse
/// de 18 % sur la période affichée.
Computed<double> computeSeriesChange(List<PricePoint> points) {
  if (points.length < 2) {
    return const Unavailable(UnavailableReason.notEnoughPrices);
  }
  return computeVariation(start: points.first.value, end: points.last.value);
}

/// Effet de change sur la durée de [bars], historique d'un actif coté en
/// dollars : performance en dollars, et ce qu'elle devient en euros.
Computed<CurrencyEffect> computeCurrencyEffectOverBars(
  List<PriceBar> bars, {
  required List<FxRate> eurUsdRates,
}) {
  if (bars.length < 2) {
    return const Unavailable(UnavailableReason.notEnoughPrices);
  }
  final performanceUsd = computeVariation(
    start: bars.first.close,
    end: bars.last.close,
  );
  final rateAtStart = findLastOnOrBefore(
    eurUsdRates,
    bars.first.day,
    dayOf: (rate) => rate.day,
  );
  final rateAtEnd = findLastOnOrBefore(
    eurUsdRates,
    bars.last.day,
    dayOf: (rate) => rate.day,
  );

  return switch ((performanceUsd, rateAtStart, rateAtEnd)) {
    (
      Available(value: final performance),
      Available(value: final start),
      Available(value: final end),
    ) =>
      computeCurrencyEffect(
        performanceUsd: performance,
        rateAtStart: start.rate,
        rateAtEnd: end.rate,
      ),
    (Unavailable(:final reason), _, _) => Unavailable(reason),
    (_, Unavailable(:final reason), _) => Unavailable(reason),
    (_, _, Unavailable(:final reason)) => Unavailable(reason),
  };
}
