import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/risk.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset_type.dart';

import '../../helpers/computed_matchers.dart';

Matcher isAvailableValuesCloseTo(List<double> expected) {
  return isA<Available<List<double>>>().having(
    (result) => result.value,
    'value',
    pairwiseCompare<double, double>(
      expected,
      (actual, wanted) => (actual - wanted).abs() < 1e-9,
      'proche de',
    ),
  );
}

void main() {
  group('rendements quotidiens', () {
    test('calcule le rendement de chaque jour par rapport à la veille', () {
      final returns = computeDailyReturns([100, 110, 99]);

      expect(returns, isAvailableValuesCloseTo([0.10, -0.10]));
    });

    test('renvoie indisponible avec moins de deux cours', () {
      expect(
        computeDailyReturns([100]),
        isUnavailableBecause(UnavailableReason.notEnoughPrices),
      );
    });

    test('renvoie indisponible quand un cours est nul', () {
      expect(
        computeDailyReturns([100, 0, 50]),
        isUnavailableBecause(UnavailableReason.invalidPrice),
      );
    });
  });

  group('volatilité annualisée', () {
    // Rendements : +10 %, −10 %, +10 %. Leur écart-type (échantillon) vaut
    // 0,11547. Annualisé sur 252 jours : 0,11547 × √252 = 1,8330.
    const closes = [100.0, 110.0, 99.0, 108.9];

    test(
      'annualise l\'écart-type des rendements sur 252 jours pour une action',
      () {
        final volatility = computeAnnualizedVolatility(
          closes,
          assetType: AssetType.stock,
        );

        expect(volatility, isAvailableCloseTo(1.8330, delta: 1e-4));
      },
    );

    test('annualise sur 365 jours pour une crypto', () {
      final volatility = computeAnnualizedVolatility(
        closes,
        assetType: AssetType.crypto,
      );

      expect(volatility, isAvailableCloseTo(2.2061, delta: 1e-4));
    });

    test('renvoie une volatilité nulle pour un cours qui ne bouge pas', () {
      final volatility = computeAnnualizedVolatility([
        100,
        100,
        100,
      ], assetType: AssetType.stock);

      expect(volatility, isAvailableCloseTo(0));
    });

    test('renvoie indisponible avec moins de deux rendements', () {
      final volatility = computeAnnualizedVolatility([
        100,
        110,
      ], assetType: AssetType.stock);

      expect(
        volatility,
        isUnavailableBecause(UnavailableReason.notEnoughPrices),
      );
    });
  });

  group('plus forte baisse', () {
    test('retrouve l\'exemple de l\'annexe A.2 de l\'énoncé : −28 %', () {
      final drawdown = computeMaxDrawdown([100, 110, 125, 115, 90, 105]);

      expect(drawdown, isAvailableCloseTo(-0.28));
    });

    test('vaut 0 pour une série toujours croissante', () {
      expect(computeMaxDrawdown([100, 110, 125]), isAvailableCloseTo(0));
    });

    test('mesure la chute complète d\'une série toujours décroissante', () {
      expect(computeMaxDrawdown([100, 80, 50]), isAvailableCloseTo(-0.5));
    });

    test('retient la plus forte de plusieurs baisses', () {
      final drawdown = computeMaxDrawdown([100, 80, 120, 90, 130]);

      expect(drawdown, isAvailableCloseTo(-0.25));
    });

    test('renvoie indisponible pour une série vide', () {
      expect(
        computeMaxDrawdown(<double>[]),
        isUnavailableBecause(UnavailableReason.notEnoughPrices),
      );
    });

    test('renvoie indisponible quand un cours est nul', () {
      expect(
        computeMaxDrawdown([0, 100, 80]),
        isUnavailableBecause(UnavailableReason.invalidPrice),
      );
    });
  });
}
