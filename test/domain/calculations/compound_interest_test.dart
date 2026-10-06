import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/compound_interest.dart';

void main() {
  test('retrouve l\'exemple du cahier : 1 000 € à 5 % sur 10 ans', () {
    final capital = computeCompoundedCapital(
      initialCapital: 1000,
      annualRate: 0.05,
      years: 10,
    );

    expect(capital, closeTo(1628.89, 0.005));
  });

  test('rend le capital de départ après 0 an', () {
    final capital = computeCompoundedCapital(
      initialCapital: 1000,
      annualRate: 0.05,
      years: 0,
    );

    expect(capital, 1000);
  });

  test('fait fondre le capital avec un taux négatif', () {
    final capital = computeCompoundedCapital(
      initialCapital: 1000,
      annualRate: -0.10,
      years: 1,
    );

    expect(capital, closeTo(900, 1e-9));
  });
}
