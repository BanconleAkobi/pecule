class CurrencyEffect {
  const CurrencyEffect({
    required this.performanceUsd,
    required this.performanceEur,
  });

  final double performanceUsd;
  final double performanceEur;

  /// Écart dû au taux de change : −0,0536 signifie 5,36 points de moins
  /// pour un investisseur qui compte en euros.
  double get effectInPoints => performanceEur - performanceUsd;
}
