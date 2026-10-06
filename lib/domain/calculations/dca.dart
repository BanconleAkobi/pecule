import 'package:pecule/domain/calculations/calendar.dart';
import 'package:pecule/domain/calculations/currency.dart';
import 'package:pecule/domain/calculations/dated_lookup.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/dca_plan.dart';
import 'package:pecule/domain/models/dca_result.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';

/// Dates d'achat prévues, de la date de début à [today] inclus.
List<DateTime> scheduleDcaPurchases(DcaPlan plan, {required DateTime today}) {
  final dates = <DateTime>[];
  for (var period = 0; ; period++) {
    final date = _purchaseDate(plan, period);
    if (date.isAfter(today)) return dates;
    dates.add(date);
  }
}

/// Rejoue un investissement régulier sur les cours passés (cahier des
/// charges, section 8.3). [bars] et [eurUsdRates] sont triés par jour
/// croissant.
Computed<DcaResult> simulateDca(
  DcaPlan plan, {
  required List<PriceBar> bars,
  required List<FxRate> eurUsdRates,
  required Currency priceCurrency,
  required DateTime today,
}) {
  if (plan.periodicAmountEur <= 0) {
    return const Unavailable(UnavailableReason.invalidAmount);
  }
  if (plan.startDate.isAfter(today)) {
    return const Unavailable(UnavailableReason.startInFuture);
  }

  final barsInRange = bars
      .where((bar) => !bar.day.isBefore(plan.startDate))
      .where((bar) => !bar.day.isAfter(today))
      .toList();
  if (barsInRange.isEmpty) {
    return const Unavailable(UnavailableReason.noPriceAfterStart);
  }

  final closesEur = <double>[];
  for (final bar in barsInRange) {
    switch (_closeInEur(bar, eurUsdRates: eurUsdRates, from: priceCurrency)) {
      case Available(:final value):
        closesEur.add(value);
      case Unavailable(:final reason):
        return Unavailable(reason);
    }
  }

  final purchasesPerBar = _countPurchasesPerBar(
    scheduleDcaPurchases(plan, today: today),
    barsInRange,
  );

  var purchaseCount = 0;
  var quantity = 0.0;
  final points = <DcaPoint>[];
  for (var index = 0; index < barsInRange.length; index++) {
    final purchases = purchasesPerBar[index];
    purchaseCount += purchases;
    quantity += purchases * plan.periodicAmountEur / closesEur[index];
    points.add(
      DcaPoint(
        day: barsInRange[index].day,
        investedEur: purchaseCount * plan.periodicAmountEur,
        valueEur: quantity * closesEur[index],
      ),
    );
  }

  return Available(
    DcaResult(
      purchaseCount: purchaseCount,
      investedEur: purchaseCount * plan.periodicAmountEur,
      totalQuantity: quantity,
      finalValueEur: points.last.valueEur,
      points: points,
    ),
  );
}

DateTime _purchaseDate(DcaPlan plan, int period) {
  final start = plan.startDate;
  return switch (plan.frequency) {
    DcaFrequency.weekly => DateTime.utc(
      start.year,
      start.month,
      start.day + 7 * period,
    ),
    // On part toujours de la date de début, pour ne pas glisser au 28 les
    // mois qui suivent un mois de février.
    DcaFrequency.monthly => addMonths(start, period),
  };
}

// Chaque achat se fait au premier cours publié à partir de sa date. Un achat
// sans cours après lui (prévu aujourd'hui, cours pas encore publié) n'a pas
// encore eu lieu.
List<int> _countPurchasesPerBar(List<DateTime> dates, List<PriceBar> bars) {
  final counts = List.filled(bars.length, 0);
  var barIndex = 0;
  for (final date in dates) {
    while (barIndex < bars.length && bars[barIndex].day.isBefore(date)) {
      barIndex++;
    }
    if (barIndex == bars.length) break;
    counts[barIndex]++;
  }
  return counts;
}

Computed<double> _closeInEur(
  PriceBar bar, {
  required List<FxRate> eurUsdRates,
  required Currency from,
}) {
  if (from == Currency.eur) return Available(bar.close);

  final rate = findLastOnOrBefore(
    eurUsdRates,
    bar.day,
    dayOf: (rate) => rate.day,
  );
  return switch (rate) {
    Available(value: final rate) => Available(
      convertToEur(bar.close, from: from, eurUsdRate: rate.rate),
    ),
    Unavailable(:final reason) => Unavailable(reason),
  };
}
