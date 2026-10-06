enum Currency {
  eur('EUR', '€'),
  usd('USD', r'$');

  const Currency(this.code, this.symbol);

  final String code;
  final String symbol;
}
