/// Mémoire de synchronisation d'une ressource : un actif (`asset:AAPL`) ou
/// une paire de devises (`fx:EUR:USD`).
class SyncState {
  const SyncState({
    required this.resourceKey,
    required this.lastDataDay,
    required this.lastFetchedAt,
  });

  final String resourceKey;

  /// Jour le plus récent présent en base.
  final DateTime lastDataDay;

  /// Dernier appel réussi à l'API.
  final DateTime lastFetchedAt;
}
