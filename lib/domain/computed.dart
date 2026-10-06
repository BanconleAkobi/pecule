/// Résultat d'un calcul métier : soit une valeur, soit la raison pour laquelle
/// le calcul est impossible. Remplace `null` et les `0` par défaut
/// (cahier des charges, section 8.1).
sealed class Computed<T> {
  const Computed();
}

final class Available<T> extends Computed<T> {
  const Available(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is Available<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Unavailable<T> extends Computed<T> {
  const Unavailable(this.reason);

  final UnavailableReason reason;

  @override
  bool operator ==(Object other) =>
      other is Unavailable<T> && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;
}

enum UnavailableReason {
  emptyPortfolio,
  nothingInvested,
  invalidAmount,
  invalidPrice,
  invalidRate,
  missingPrice,
  noDataForDate,
  notEnoughPrices,
  startInFuture,
  noPriceAfterStart,

  /// L'effet de change n'a pas de sens pour un actif coté en euros.
  sameCurrency,
}
