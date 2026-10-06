import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/remote/dto/frankfurter_dto.dart';

import '../../../helpers/fixtures.dart';

void main() {
  final rates = readJsonListFixture('frankfurter_rates_eur_usd.json')
      .map((json) => FrankfurterRateDto.fromJson(json as Map<String, dynamic>));

  test('lit un taux par jour, week-ends compris', () {
    expect(rates, hasLength(12));
    expect(
      rates.map((rate) => rate.day),
      containsAll([DateTime.utc(2026, 9, 26), DateTime.utc(2026, 9, 27)]),
    );
  });

  test('lit la devise de base, la devise cotée et le taux', () {
    final first = rates.first;

    expect(first.day, DateTime.utc(2026, 9, 21));
    expect(first.base, 'EUR');
    expect(first.quote, 'USD');
    expect(first.rate, 1.1481);
  });

  test(
    'avec une date de début seule, lit les taux jusqu\'au jour de la requête',
    () {
      final openEnded = readJsonListFixture('frankfurter_rates_open_ended.json')
          .map(
            (json) => FrankfurterRateDto.fromJson(json as Map<String, dynamic>),
          );

      expect(openEnded.first.day, DateTime.utc(2026, 9, 28));
      expect(openEnded.last.day, DateTime.utc(2026, 10, 6));
    },
  );
}
