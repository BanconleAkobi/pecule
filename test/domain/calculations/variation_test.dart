import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/variation.dart';
import 'package:pecule/domain/computed.dart';

import '../../helpers/computed_matchers.dart';

void main() {
  test('calcule une hausse entre deux cours', () {
    expect(computeVariation(start: 100, end: 118), isAvailableCloseTo(0.18));
  });

  test('calcule une baisse entre deux cours', () {
    expect(computeVariation(start: 200, end: 150), isAvailableCloseTo(-0.25));
  });

  test('vaut 0 quand le cours n\'a pas bougé', () {
    expect(computeVariation(start: 42, end: 42), isAvailableCloseTo(0));
  });

  test('renvoie indisponible quand le cours de départ est nul', () {
    expect(
      computeVariation(start: 0, end: 10),
      isUnavailableBecause(UnavailableReason.invalidPrice),
    );
  });
}
