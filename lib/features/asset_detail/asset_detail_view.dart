import 'package:pecule/core/cached_data.dart';
import 'package:pecule/domain/calculations/price_series.dart';
import 'package:pecule/domain/calculations/stability_score.dart';
import 'package:pecule/domain/calculations/variation.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/currency_effect.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:pecule/domain/models/price_point.dart';
import 'package:pecule/domain/models/stability_score.dart';

/// Tout ce que la fiche d'un actif affiche pour une période.
class AssetDetailView {
  const AssetDetailView({
    required this.asset,
    required this.period,
    required this.points,
    required this.periodChange,
    required this.yearChange,
    required this.currencyEffect,
    required this.stability,
    required this.updatedAt,
    required this.refreshError,
  });

  final Asset asset;
  final ChartPeriod period;

  /// Les cours de la période, en euros : la courbe.
  final List<PricePoint> points;

  final Computed<double> periodChange;
  final Computed<double> yearChange;

  /// Sur la période, comme la variation de l'en-tête.
  final Computed<CurrencyEffect> currencyEffect;

  /// Sur un an glissant, en devise d'origine : il décrit l'actif lui-même,
  /// sans l'effet de change.
  final Computed<StabilityScore> stability;

  final DateTime? updatedAt;
  final Object? refreshError;

  bool get hasPrices => points.isNotEmpty;
  bool get isStale => refreshError != null;
}

AssetDetailView buildAssetDetailView({
  required Asset asset,
  required ChartPeriod period,
  required CachedData<List<PriceBar>> history,
  required List<FxRate> eurUsdRates,
  required DateTime today,
}) {
  final bars = history.value;
  final allPoints = closesInEur(
    bars,
    currency: asset.currency,
    eurUsdRates: eurUsdRates,
  );
  List<PricePoint> pointsIn(ChartPeriod period) => itemsInPeriod(
    allPoints,
    period,
    today: today,
    dayOf: (point) => point.day,
  );
  List<PriceBar> barsIn(ChartPeriod period) =>
      itemsInPeriod(bars, period, today: today, dayOf: (bar) => bar.day);

  final points = pointsIn(period);
  return AssetDetailView(
    asset: asset,
    period: period,
    points: points,
    periodChange: computeSeriesChange(points),
    yearChange: computeSeriesChange(pointsIn(ChartPeriod.oneYear)),
    currencyEffect: asset.currency == Currency.eur
        ? const Unavailable(UnavailableReason.sameCurrency)
        : computeCurrencyEffectOverBars(
            barsIn(period),
            eurUsdRates: eurUsdRates,
          ),
    stability: assessStability([
      for (final bar in barsIn(ChartPeriod.oneYear)) bar.close,
    ], assetType: asset.type),
    updatedAt: history.updatedAt,
    refreshError: history.refreshError,
  );
}

/// Ce que l'en-tête affiche : le dernier cours, ou celui du point touché sur
/// la courbe, et la variation depuis le début de la période jusqu'à lui.
class ChartReading {
  const ChartReading({
    required this.priceEur,
    required this.change,
    required this.scrubbedDay,
  });

  final double priceEur;
  final Computed<double> change;

  /// Le jour touché, vide quand le doigt n'est pas sur la courbe.
  final DateTime? scrubbedDay;
}

/// Vide quand la période n'a aucun cours.
ChartReading? readChart(AssetDetailView view, {int? scrubIndex}) {
  final points = view.points;
  if (points.isEmpty) return null;

  final index = scrubIndex == null
      ? points.length - 1
      : scrubIndex.clamp(0, points.length - 1);
  final point = points[index];
  return ChartReading(
    priceEur: point.value,
    change: computeVariation(start: points.first.value, end: point.value),
    scrubbedDay: scrubIndex == null ? null : point.day,
  );
}
