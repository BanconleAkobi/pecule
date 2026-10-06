import 'package:pecule/core/formatters.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/domain/models/currency_effect.dart';
import 'package:pecule/domain/models/stability_score.dart';

// Les phrases de la fiche, au tutoiement, avec les chiffres de l'actif
// (cahier des charges, section 4.4 ; textes de la maquette).

String periodButtonLabel(ChartPeriod period) => switch (period) {
  ChartPeriod.oneMonth => '1M',
  ChartPeriod.sixMonths => '6M',
  ChartPeriod.oneYear => '1A',
  ChartPeriod.threeYears => '3A',
  ChartPeriod.max => 'Max',
};

String periodCaption(ChartPeriod period) => switch (period) {
  ChartPeriod.oneMonth => 'sur 1 mois',
  ChartPeriod.sixMonths => 'sur 6 mois',
  ChartPeriod.oneYear => 'sur 1 an',
  ChartPeriod.threeYears => 'sur 3 ans',
  ChartPeriod.max => 'depuis le début',
};

String _periodStart(ChartPeriod period) => switch (period) {
  ChartPeriod.oneMonth => 'il y a un mois',
  ChartPeriod.sixMonths => 'il y a six mois',
  ChartPeriod.oneYear => 'il y a un an',
  ChartPeriod.threeYears => 'il y a trois ans',
  ChartPeriod.max => 'au début de l\'historique',
};

String explainChangeTitle(double change) =>
    '${formatPercent(change)}, en clair';

/// [isScrubbing] : le doigt est sur la courbe, la variation s'arrête au
/// jour touché.
String explainChangeText({
  required String assetName,
  required double change,
  required ChartPeriod period,
  required bool isScrubbing,
}) {
  final start = isScrubbing ? 'au début de la période' : _periodStart(period);
  final end = isScrubbing ? 'à cette date' : 'aujourd\'hui';
  final value = formatEur(100 * (1 + change));
  return 'Si tu avais mis 100 € dans $assetName $start, tu aurais $value $end.';
}

String currencyEffectText(CurrencyEffect effect) {
  final from = formatUsdPerEuro(effect.rateAtStart);
  final to = formatUsdPerEuro(effect.rateAtEnd);
  final points = formatPoints(effect.effectInPoints);
  if (points == '0') {
    return 'Le taux de l\'euro n\'a presque pas bougé : la performance est la '
        'même pour toi.';
  }
  if (effect.effectInPoints < 0) {
    return 'Sur la période, l\'euro est passé de $from à $to. Tes dollars '
        'valent donc moins d\'euros : $points points de moins pour toi.';
  }
  return 'Sur la période, l\'euro est passé de $from à $to. Tes dollars valent '
      'donc plus d\'euros : $points points de plus pour toi.';
}

String stabilityLevelLabel(StabilityLevel level) => switch (level) {
  StabilityLevel.stable => 'Stable',
  StabilityLevel.moderate => 'Modéré',
  StabilityLevel.agitated => 'Agité',
};

const stabilityExplanation =
    'On note séparément les variations du prix et sa pire chute. Le score est '
    'la moyenne des deux : plus un actif bouge et chute, plus il baisse.';

const pastDisclaimer = 'Basé sur le passé, ce n\'est pas une prédiction.';

const notEnoughHistory = 'Pas encore assez d\'historique pour le calculer.';

String performanceCardText({
  required String assetName,
  required double yearChange,
}) {
  final value = formatEur(100 * (1 + yearChange));
  return 'Si tu avais mis 100 € dans $assetName il y a un an, tu aurais '
      'aujourd\'hui $value.';
}

String volatilityCardText({
  required String assetName,
  required AssetType type,
  required double volatility,
}) {
  return 'Sur un an, le cours de $assetName s\'est éloigné de sa moyenne '
      'd\'environ ${formatRoundPercent(volatility)}. '
      '${_calmness(volatility)} pour ${_withArticle(type)}.';
}

String drawdownCardText({required double maxDrawdown}) {
  return 'Au pire moment de l\'année, quelqu\'un qui avait acheté au plus haut '
      'perdait ${formatRoundPercent(maxDrawdown)}.';
}

// Seuils de la maquette pour qualifier une volatilité annuelle.
const _veryCalmBelow = 0.18;
const _ratherCalmBelow = 0.30;
const _ratherAgitatedBelow = 0.55;

String _calmness(double volatility) {
  if (volatility < _veryCalmBelow) return 'C\'est très calme';
  if (volatility < _ratherCalmBelow) return 'C\'est plutôt calme';
  if (volatility < _ratherAgitatedBelow) return 'C\'est assez agité';
  return 'C\'est très agité';
}

String _withArticle(AssetType type) => switch (type) {
  AssetType.stock => 'une action',
  AssetType.etf => 'un ETF',
  AssetType.crypto => 'une crypto',
};
