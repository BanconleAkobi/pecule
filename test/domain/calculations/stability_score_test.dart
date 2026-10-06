import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/stability_score.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/stability_score.dart';

import '../../helpers/computed_matchers.dart';

void main() {
  group('score de stabilité', () {
    test(
      'retrouve l\'exemple du cahier : 20 % et −25 % donnent 72, Stable',
      () {
        final score = computeStabilityScore(
          volatility: 0.20,
          maxDrawdown: -0.25,
        );

        expect(score.volatilityNote, closeTo(75, 1e-9));
        expect(score.drawdownNote, closeTo(68.75, 1e-9));
        expect(score.value, 72);
        expect(score.level, StabilityLevel.stable);
      },
    );

    test('donne 100 à un actif qui n\'a ni bougé ni baissé', () {
      final score = computeStabilityScore(volatility: 0, maxDrawdown: 0);

      expect(score.value, 100);
    });

    test('plafonne la volatilité à 80 % : au-delà, la note vaut 0', () {
      final score = computeStabilityScore(volatility: 1.20, maxDrawdown: 0);

      expect(score.volatilityNote, 0);
    });

    test('plafonne la baisse à 80 % : au-delà, la note vaut 0', () {
      final score = computeStabilityScore(volatility: 0, maxDrawdown: -0.90);

      expect(score.drawdownNote, 0);
    });

    test('garde les valeurs brutes pour le détail affiché', () {
      final score = computeStabilityScore(volatility: 0.20, maxDrawdown: -0.25);

      expect(score.volatility, 0.20);
      expect(score.maxDrawdown, -0.25);
    });
  });

  group('libellé du score', () {
    test('39 est Agité', () {
      expect(stabilityLevelFor(39), StabilityLevel.agitated);
    });

    test('40 est Modéré', () {
      expect(stabilityLevelFor(40), StabilityLevel.moderate);
    });

    test('69 est Modéré', () {
      expect(stabilityLevelFor(69), StabilityLevel.moderate);
    });

    test('70 est Stable', () {
      expect(stabilityLevelFor(70), StabilityLevel.stable);
    });
  });

  group('évaluation à partir des cours', () {
    test('combine la volatilité et la plus forte baisse des cours', () {
      final result = assessStability([
        100,
        100,
        100,
      ], assetType: AssetType.stock);

      expect(
        result,
        isA<Available<StabilityScore>>().having(
          (found) => found.value.value,
          'value',
          100,
        ),
      );
    });

    test('renvoie indisponible quand l\'historique est trop court', () {
      final result = assessStability([100, 110], assetType: AssetType.stock);

      expect(result, isUnavailableBecause(UnavailableReason.notEnoughPrices));
    });
  });
}
