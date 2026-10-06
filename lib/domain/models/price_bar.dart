class PriceBar {
  const PriceBar({
    required this.day,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.marketCap,
  });

  final DateTime day;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  // Fournie uniquement pour les cryptos.
  final double? marketCap;
}
