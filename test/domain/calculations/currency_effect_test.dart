import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/currency.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/currency_effect.dart';

import '../../helpers/computed_matchers.dart';

Matcher isEffect({required double performanceEur, required double points}) {
  return isA<Available<CurrencyEffect>>()
      .having(
        (found) => found.value.performanceEur,
        'performanceEur',
        closeTo(performanceEur, 1e-4),
      )
      .having(
        (found) => found.value.effectInPoints,
        'effectInPoints',
        closeTo(points, 1e-4),
      );
}

void main() {
  test('retrouve l\'exemple du cahier : +18 % en dollars, euro de 1,05 à 1,10, '
      'donnent +12,6 % en euros', () {
    final effect = computeCurrencyEffect(
      performanceUsd: 0.18,
      rateAtStart: 1.05,
      rateAtEnd: 1.10,
    );

    expect(effect, isEffect(performanceEur: 0.1264, points: -0.0536));
  });

  test('ne change rien quand le taux n\'a pas bougé', () {
    final effect = computeCurrencyEffect(
      performanceUsd: 0.18,
      rateAtStart: 1.10,
      rateAtEnd: 1.10,
    );

    expect(effect, isEffect(performanceEur: 0.18, points: 0));
  });

  test('profite à l\'investisseur européen quand l\'euro baisse', () {
    final effect = computeCurrencyEffect(
      performanceUsd: 0,
      rateAtStart: 1.10,
      rateAtEnd: 1.00,
    );

    expect(effect, isEffect(performanceEur: 0.10, points: 0.10));
  });

  test('renvoie indisponible pour un taux nul', () {
    final effect = computeCurrencyEffect(
      performanceUsd: 0.18,
      rateAtStart: 0,
      rateAtEnd: 1.10,
    );

    expect(effect, isUnavailableBecause(UnavailableReason.invalidRate));
  });
}
