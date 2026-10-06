/// Un jour de la courbe : ce qui a été investi jusque-là et ce que ça vaut.
class DcaPoint {
  const DcaPoint({
    required this.day,
    required this.investedEur,
    required this.valueEur,
  });

  final DateTime day;
  final double investedEur;
  final double valueEur;
}

/// Toujours au moins un achat : une simulation sans achat est indisponible.
class DcaResult {
  const DcaResult({
    required this.purchaseCount,
    required this.investedEur,
    required this.totalQuantity,
    required this.finalValueEur,
    required this.points,
  });

  final int purchaseCount;
  final double investedEur;
  final double totalQuantity;
  final double finalValueEur;
  final List<DcaPoint> points;

  double get performance => finalValueEur / investedEur - 1;

  double get averagePriceEur => investedEur / totalQuantity;
}
