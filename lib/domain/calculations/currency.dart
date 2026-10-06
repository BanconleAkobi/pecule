import 'package:pecule/domain/models/currency.dart';

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
