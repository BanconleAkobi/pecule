class CurrencyEffect {
  const CurrencyEffect({
    required this.performanceUsd,
    required this.performanceEur,
    required this.rateAtStart,
    required this.rateAtEnd,
  });

  final double performanceUsd;
  final double performanceEur;

  /// Taux EUR/USD au début et à la fin de la période : dollars pour un euro.
  final double rateAtStart;
  final double rateAtEnd;

  /// Écart dû au taux de change : −0,0536 signifie 5,36 points de moins
  /// pour un investisseur qui compte en euros.
  double get effectInPoints => performanceEur - performanceUsd;
}
