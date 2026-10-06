import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/dated_lookup.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';

import '../../helpers/computed_matchers.dart';

FxRate rateOn(DateTime day, double rate) =>
    FxRate(day: day, base: Currency.eur, quote: Currency.usd, rate: rate);

Matcher isRate(double expected) => isA<Available<FxRate>>().having(
  (found) => found.value.rate,
  'rate',
  expected,
);

void main() {
  final friday = DateTime.utc(2026, 1, 2);
  final sunday = DateTime.utc(2026, 1, 4);
  final monday = DateTime.utc(2026, 1, 5);
  final rates = [rateOn(friday, 1.03), rateOn(monday, 1.04)];

  Computed<FxRate> lookup(List<FxRate> series, DateTime day) =>
      findLastOnOrBefore(series, day, dayOf: (rate) => rate.day);

  test('renvoie la valeur du jour quand elle existe', () {
    expect(lookup(rates, monday), isRate(1.04));
  });

  test('renvoie la valeur du vendredi pour un dimanche', () {
    expect(lookup(rates, sunday), isRate(1.03));
  });

  test('renvoie la dernière valeur pour une date après la série', () {
    expect(lookup(rates, DateTime.utc(2026, 2, 3)), isRate(1.04));
  });

  test('renvoie indisponible pour une date avant la première valeur', () {
    expect(
      lookup(rates, DateTime.utc(2025, 12, 31)),
      isUnavailableBecause(UnavailableReason.noDataForDate),
    );
  });

  test('renvoie indisponible pour une série vide', () {
    expect(
      lookup([], monday),
      isUnavailableBecause(UnavailableReason.noDataForDate),
    );
  });
}
