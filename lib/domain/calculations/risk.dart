import 'dart:math' as math;

import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset_type.dart';

Computed<List<double>> computeDailyReturns(List<double> closes) {
  if (closes.length < 2) {
    return const Unavailable(UnavailableReason.notEnoughPrices);
  }
  if (closes.any((close) => close <= 0)) {
    return const Unavailable(UnavailableReason.invalidPrice);
  }
  return Available([
    for (var day = 1; day < closes.length; day++)
      closes[day] / closes[day - 1] - 1,
  ]);
}

/// Écart-type des rendements quotidiens, ramené à l'année : × √252 pour les
/// actions et ETF, × √365 pour les cryptos.
Computed<double> computeAnnualizedVolatility(
  List<double> closes, {
  required AssetType assetType,
}) {
  switch (computeDailyReturns(closes)) {
    case Unavailable(:final reason):
      return Unavailable(reason);
    case Available(value: final returns):
      if (returns.length < 2) {
        return const Unavailable(UnavailableReason.notEnoughPrices);
      }
      final annualizationFactor = math.sqrt(assetType.tradingDaysPerYear);
      return Available(_sampleStandardDeviation(returns) * annualizationFactor);
  }
}

/// Plus forte baisse entre un sommet et le creux qui le suit, en valeur
/// négative : −0,28 pour une chute de 28 %.
Computed<double> computeMaxDrawdown(List<double> closes) {
  if (closes.isEmpty) {
    return const Unavailable(UnavailableReason.notEnoughPrices);
  }
  if (closes.any((close) => close <= 0)) {
    return const Unavailable(UnavailableReason.invalidPrice);
  }

  var peak = closes.first;
  var maxDrawdown = 0.0;
  for (final close in closes) {
    peak = math.max(peak, close);
    maxDrawdown = math.min(maxDrawdown, close / peak - 1);
  }
  return Available(maxDrawdown);
}

// Division par n − 1 : on estime la dispersion à partir d'un échantillon de
// jours, pas de toute l'histoire de l'actif.
double _sampleStandardDeviation(List<double> values) {
  final mean = values.reduce((sum, value) => sum + value) / values.length;
  final sumOfSquares = values.fold<double>(
    0,
    (sum, value) => sum + (value - mean) * (value - mean),
  );
  return math.sqrt(sumOfSquares / (values.length - 1));
}
