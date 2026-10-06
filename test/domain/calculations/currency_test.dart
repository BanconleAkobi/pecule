import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/currency.dart';
import 'package:pecule/domain/models/currency.dart';

void main() {
  test('convertit un prix en dollars en euros avec le taux du jour', () {
    final priceEur = convertToEur(110, from: Currency.usd, eurUsdRate: 1.10);

    expect(priceEur, closeTo(100, 1e-9));
  });

  test('laisse un prix en euros inchangé, quel que soit le taux', () {
    final priceEur = convertToEur(50, from: Currency.eur, eurUsdRate: 1.10);

    expect(priceEur, 50);
  });
}
