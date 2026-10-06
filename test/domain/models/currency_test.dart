import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/models/currency.dart';

void main() {
  test('retrouve une devise par son code ISO', () {
    expect(Currency.fromCode('USD'), Currency.usd);
    expect(Currency.fromCode('EUR'), Currency.eur);
  });

  test('refuse un code de devise inconnu', () {
    expect(() => Currency.fromCode('GBP'), throwsStateError);
  });
}
