enum Currency {
  eur('EUR', '€'),
  usd('USD', r'$');

  const Currency(this.code, this.symbol);

  static Currency fromCode(String code) =>
      values.firstWhere((currency) => currency.code == code);

  final String code;
  final String symbol;
}
