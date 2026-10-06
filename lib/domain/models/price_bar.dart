class PriceBar {
  const PriceBar({
    required this.day,
    required this.close,
    required this.volume,
    this.open,
    this.high,
    this.low,
    this.marketCap,
  });

  final DateTime day;
  final double close;
  final double volume;

  // CoinGecko ne fournit que la clôture des cryptos : ouverture, plus haut et
  // plus bas n'existent que pour les actions et ETF. Aucun calcul ne s'en sert.
  final double? open;
  final double? high;
  final double? low;

  // Fournie uniquement pour les cryptos.
  final double? marketCap;
}
