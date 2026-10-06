import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/dca.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/dca_plan.dart';
import 'package:pecule/domain/models/dca_result.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';

import '../../helpers/computed_matchers.dart';

PriceBar bar(DateTime day, double close) => PriceBar(
  day: day,
  open: close,
  high: close,
  low: close,
  close: close,
  volume: 0,
);

FxRate rate(DateTime day, double eurUsd) =>
    FxRate(day: day, base: Currency.eur, quote: Currency.usd, rate: eurUsd);

DateTime day(int month, int dayOfMonth) =>
    DateTime.utc(2026, month, dayOfMonth);

DcaResult resultOf(Computed<DcaResult> computed) =>
    (computed as Available<DcaResult>).value;

void main() {
  group('dates d\'achat', () {
    test('chaque semaine, ajoute sept jours jusqu\'à aujourd\'hui inclus', () {
      final dates = scheduleDcaPurchases(
        DcaPlan(
          periodicAmountEur: 50,
          frequency: DcaFrequency.weekly,
          startDate: day(1, 5),
        ),
        today: day(1, 19),
      );

      expect(dates, [day(1, 5), day(1, 12), day(1, 19)]);
    });

    test('chaque mois, garde le même jour du mois', () {
      final dates = scheduleDcaPurchases(
        DcaPlan(
          periodicAmountEur: 50,
          frequency: DcaFrequency.monthly,
          startDate: day(1, 5),
        ),
        today: day(3, 10),
      );

      expect(dates, [day(1, 5), day(2, 5), day(3, 5)]);
    });

    test('ramène au dernier jour du mois quand le jour n\'existe pas', () {
      final dates = scheduleDcaPurchases(
        DcaPlan(
          periodicAmountEur: 50,
          frequency: DcaFrequency.monthly,
          startDate: day(1, 31),
        ),
        today: day(3, 31),
      );

      expect(dates, [day(1, 31), day(2, 28), day(3, 31)]);
    });
  });

  group('simulation', () {
    // 100 € chaque mois depuis le jeudi 1er janvier. Les dates prévues
    // tombent un jour férié ou un dimanche : chaque achat se fait au premier
    // cours qui suit. Quantités : 100/10 + 100/20 + 100/10 = 25.
    final monthlyPlan = DcaPlan(
      periodicAmountEur: 100,
      frequency: DcaFrequency.monthly,
      startDate: day(1, 1),
    );
    final monthlyBars = [
      bar(day(1, 2), 10),
      bar(day(2, 2), 20),
      bar(day(3, 2), 10),
      bar(day(3, 31), 25),
    ];

    DcaResult simulateMonthlyPlan() => resultOf(
      simulateDca(
        monthlyPlan,
        bars: monthlyBars,
        eurUsdRates: [],
        priceCurrency: Currency.eur,
        today: day(3, 31),
      ),
    );

    test('achète au premier cours disponible à partir de chaque date', () {
      final result = simulateMonthlyPlan();

      expect(result.purchaseCount, 3);
      expect(result.investedEur, closeTo(300, 1e-9));
      expect(result.totalQuantity, closeTo(25, 1e-9));
    });

    test('valorise les quantités au dernier cours connu', () {
      final result = simulateMonthlyPlan();

      expect(result.finalValueEur, closeTo(625, 1e-9));
      expect(result.performance, closeTo(625 / 300 - 1, 1e-9));
      expect(result.averagePriceEur, closeTo(12, 1e-9));
    });

    test('construit la courbe du capital investi et de la valeur', () {
      final points = simulateMonthlyPlan().points;

      expect(points.map((point) => point.day), [
        day(1, 2),
        day(2, 2),
        day(3, 2),
        day(3, 31),
      ]);
      expect(points.map((point) => point.investedEur), [100, 200, 300, 300]);
      expect(points.map((point) => point.valueEur), [100, 300, 250, 625]);
    });

    test('convertit chaque achat au taux du jour pour un actif en dollars', () {
      final result = resultOf(
        simulateDca(
          DcaPlan(
            periodicAmountEur: 100,
            frequency: DcaFrequency.monthly,
            startDate: day(1, 2),
          ),
          bars: [bar(day(1, 2), 11), bar(day(1, 9), 22)],
          eurUsdRates: [rate(day(1, 2), 1.10), rate(day(1, 9), 1.00)],
          priceCurrency: Currency.usd,
          today: day(1, 9),
        ),
      );

      expect(result.totalQuantity, closeTo(10, 1e-9));
      expect(result.finalValueEur, closeTo(220, 1e-9));
    });

    test('utilise le même cours pour deux achats tombés dans un trou', () {
      final result = resultOf(
        simulateDca(
          DcaPlan(
            periodicAmountEur: 100,
            frequency: DcaFrequency.weekly,
            startDate: day(1, 5),
          ),
          bars: [bar(day(1, 5), 10), bar(day(1, 19), 20)],
          eurUsdRates: [],
          priceCurrency: Currency.eur,
          today: day(1, 19),
        ),
      );

      expect(result.purchaseCount, 3);
      expect(result.totalQuantity, closeTo(10 + 5 + 5, 1e-9));
    });

    test('compte un dernier achat qui tombe aujourd\'hui', () {
      final result = resultOf(
        simulateDca(
          DcaPlan(
            periodicAmountEur: 100,
            frequency: DcaFrequency.weekly,
            startDate: day(1, 5),
          ),
          bars: [bar(day(1, 5), 10), bar(day(1, 12), 20), bar(day(1, 19), 40)],
          eurUsdRates: [],
          priceCurrency: Currency.eur,
          today: day(1, 19),
        ),
      );

      expect(result.purchaseCount, 3);
    });

    test(
      'ignore l\'achat du jour tant que le cours du jour n\'est pas publié',
      () {
        final result = resultOf(
          simulateDca(
            DcaPlan(
              periodicAmountEur: 100,
              frequency: DcaFrequency.weekly,
              startDate: day(1, 5),
            ),
            bars: [bar(day(1, 5), 10), bar(day(1, 12), 20)],
            eurUsdRates: [],
            priceCurrency: Currency.eur,
            today: day(1, 19),
          ),
        );

        expect(result.purchaseCount, 2);
      },
    );

    test('fait un seul achat quand une seule période s\'est écoulée', () {
      final result = resultOf(
        simulateDca(
          DcaPlan(
            periodicAmountEur: 100,
            frequency: DcaFrequency.monthly,
            startDate: day(1, 5),
          ),
          bars: [bar(day(1, 5), 10), bar(day(1, 20), 12)],
          eurUsdRates: [],
          priceCurrency: Currency.eur,
          today: day(1, 20),
        ),
      );

      expect(result.purchaseCount, 1);
      expect(result.finalValueEur, closeTo(120, 1e-9));
    });
  });

  group('simulation impossible', () {
    test('renvoie indisponible pour une date de début dans le futur', () {
      final result = simulateDca(
        DcaPlan(
          periodicAmountEur: 100,
          frequency: DcaFrequency.monthly,
          startDate: day(6, 1),
        ),
        bars: [bar(day(1, 5), 10)],
        eurUsdRates: [],
        priceCurrency: Currency.eur,
        today: day(3, 1),
      );

      expect(result, isUnavailableBecause(UnavailableReason.startInFuture));
    });

    test('renvoie indisponible quand aucun cours ne suit la date de début', () {
      final result = simulateDca(
        DcaPlan(
          periodicAmountEur: 100,
          frequency: DcaFrequency.monthly,
          startDate: day(2, 1),
        ),
        bars: [bar(day(1, 5), 10)],
        eurUsdRates: [],
        priceCurrency: Currency.eur,
        today: day(3, 1),
      );

      expect(result, isUnavailableBecause(UnavailableReason.noPriceAfterStart));
    });

    test('renvoie indisponible pour un montant nul', () {
      final result = simulateDca(
        DcaPlan(
          periodicAmountEur: 0,
          frequency: DcaFrequency.monthly,
          startDate: day(1, 5),
        ),
        bars: [bar(day(1, 5), 10)],
        eurUsdRates: [],
        priceCurrency: Currency.eur,
        today: day(3, 1),
      );

      expect(result, isUnavailableBecause(UnavailableReason.invalidAmount));
    });

    test(
      'renvoie indisponible quand un taux manque pour un actif en dollars',
      () {
        final result = simulateDca(
          DcaPlan(
            periodicAmountEur: 100,
            frequency: DcaFrequency.monthly,
            startDate: day(1, 5),
          ),
          bars: [bar(day(1, 5), 11)],
          eurUsdRates: [],
          priceCurrency: Currency.usd,
          today: day(1, 9),
        );

        expect(result, isUnavailableBecause(UnavailableReason.noDataForDate));
      },
    );
  });
}
