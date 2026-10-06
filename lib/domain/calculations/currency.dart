import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/currency_effect.dart';

/// [eurUsdRate] : dollars pour un euro, comme le publie Frankfurter.
double convertToEur(
  double amount, {
  required Currency from,
  required double eurUsdRate,
}) {
  return switch (from) {
    Currency.eur => amount,
    Currency.usd => amount / eurUsdRate,
  };
}

/// Performance vue depuis l'euro d'un actif coté en dollars (cahier des
/// charges, section 8.4). Les taux sont en dollars pour un euro : si l'euro
/// monte, chaque dollar gagné vaut moins d'euros.
Computed<CurrencyEffect> computeCurrencyEffect({
  required double performanceUsd,
  required double rateAtStart,
  required double rateAtEnd,
}) {
  if (rateAtStart <= 0 || rateAtEnd <= 0) {
    return const Unavailable(UnavailableReason.invalidRate);
  }
  final performanceEur = (1 + performanceUsd) * rateAtStart / rateAtEnd - 1;
  return Available(
    CurrencyEffect(
      performanceUsd: performanceUsd,
      performanceEur: performanceEur,
    ),
  );
}
