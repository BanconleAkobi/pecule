enum AssetType {
  stock,
  etf,
  crypto;

  // Les bourses ferment le week-end et les jours fériés, les cryptos jamais.
  int get tradingDaysPerYear => switch (this) {
    AssetType.stock || AssetType.etf => 252,
    AssetType.crypto => 365,
  };
}
