import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';

// Un an d'Apple, de 110 $ à 132 $, avec un euro stable à 1,10 $ : de 100 € à
// 120 €, soit +20 % en dollars comme en euros.
final appleYear = [
  _close(DateTime.utc(2025, 10, 7), 110),
  _close(DateTime.utc(2026, 1, 2), 115),
  _close(DateTime.utc(2026, 4, 1), 120),
  _close(DateTime.utc(2026, 7, 1), 125),
  _close(DateTime.utc(2026, 10, 7), 132),
];

final stableEuro = [
  FxRate(
    day: DateTime.utc(2025, 1, 2),
    base: Currency.eur,
    quote: Currency.usd,
    rate: 1.10,
  ),
];

PriceBar _close(DateTime day, double close) =>
    PriceBar(day: day, close: close, volume: 0);
