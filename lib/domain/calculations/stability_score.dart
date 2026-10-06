import 'dart:math' as math;

import 'package:pecule/domain/calculations/risk.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/stability_score.dart';

// Au-delà de 80 %, un actif est considéré comme au maximum de l'agitation.
const volatilityCap = 0.80;
const drawdownCap = 0.80;

const volatilityWeight = 0.5;
const drawdownWeight = 0.5;

const stableThreshold = 70;
const moderateThreshold = 40;

StabilityScore computeStabilityScore({
  required double volatility,
  required double maxDrawdown,
}) {
  final volatilityNote = _noteOutOf100(volatility, cap: volatilityCap);
  final drawdownNote = _noteOutOf100(maxDrawdown.abs(), cap: drawdownCap);
  final value =
      (volatilityWeight * volatilityNote + drawdownWeight * drawdownNote)
          .round();

  return StabilityScore(
    volatility: volatility,
    maxDrawdown: maxDrawdown,
    volatilityNote: volatilityNote,
    drawdownNote: drawdownNote,
    value: value,
    level: stabilityLevelFor(value),
  );
}

StabilityLevel stabilityLevelFor(int score) {
  if (score >= stableThreshold) return StabilityLevel.stable;
  if (score >= moderateThreshold) return StabilityLevel.moderate;
  return StabilityLevel.agitated;
}

Computed<StabilityScore> assessStability(
  List<double> closes, {
  required AssetType assetType,
}) {
  final volatility = computeAnnualizedVolatility(closes, assetType: assetType);
  final maxDrawdown = computeMaxDrawdown(closes);

  return switch ((volatility, maxDrawdown)) {
    (Available(value: final volatility), Available(value: final drawdown)) =>
      Available(
        computeStabilityScore(volatility: volatility, maxDrawdown: drawdown),
      ),
    (Unavailable(:final reason), _) => Unavailable(reason),
    (_, Unavailable(:final reason)) => Unavailable(reason),
  };
}

// 0 % donne 100, le plafond ou plus donne 0, et la note baisse en ligne droite
// entre les deux.
double _noteOutOf100(double measure, {required double cap}) {
  return 100 * (1 - math.min(measure, cap) / cap);
}
