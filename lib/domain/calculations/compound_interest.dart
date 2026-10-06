import 'dart:math' as math;

double computeCompoundedCapital({
  required double initialCapital,
  required double annualRate,
  required int years,
}) {
  return initialCapital * math.pow(1 + annualRate, years);
}
