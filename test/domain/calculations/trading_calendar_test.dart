import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/trading_calendar.dart';
import 'package:pecule/domain/models/asset_type.dart';

// Octobre 2026 : vendredi 2, samedi 3, dimanche 4, lundi 5, mercredi 7.
DateTime october(int day, [int hour = 0]) => DateTime.utc(2026, 10, day, hour);

void main() {
  group('actions et ETF', () {
    DateTime expectedAt(DateTime now) =>
        expectedLatestDay(stockMarketSchedule, now: now);

    test('après la clôture, attend le cours du jour', () {
      expect(expectedAt(october(7, 23)), october(7));
    });

    test('avant la clôture, attend le cours de la veille', () {
      expect(expectedAt(october(7, 10)), october(6));
    });

    test('un lundi matin, attend le cours du vendredi', () {
      expect(expectedAt(october(5, 10)), october(2));
    });

    test('le samedi, attend le cours du vendredi', () {
      expect(expectedAt(october(3, 23)), october(2));
    });

    test('le dimanche, attend le cours du vendredi', () {
      expect(expectedAt(october(4, 23)), october(2));
    });
  });

  group('cryptos', () {
    test('attend le cours du jour, même le dimanche', () {
      expect(
        expectedLatestDay(cryptoMarketSchedule, now: october(4, 10)),
        october(4),
      );
    });
  });

  group('taux de change', () {
    DateTime expectedAt(DateTime now) =>
        expectedLatestDay(fxRatesSchedule, now: now);

    test('avant 16 h UTC, attend le taux de la veille', () {
      expect(expectedAt(october(7, 10)), october(6));
    });

    test('après 16 h UTC, attend le taux du jour', () {
      expect(expectedAt(october(7, 17)), october(7));
    });

    test('attend aussi un taux le dimanche', () {
      expect(expectedAt(october(4, 17)), october(4));
    });
  });

  group('rythme par type d\'actif', () {
    test('les actions et les ETF suivent la bourse', () {
      expect(scheduleFor(AssetType.stock), stockMarketSchedule);
      expect(scheduleFor(AssetType.etf), stockMarketSchedule);
    });

    test('les cryptos suivent leur propre rythme', () {
      expect(scheduleFor(AssetType.crypto), cryptoMarketSchedule);
    });
  });
}
