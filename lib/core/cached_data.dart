/// Ce qu'un repository renvoie à l'écran : la valeur, sa fraîcheur et, si la
/// dernière actualisation a échoué, la raison (cahier des charges, section 9.2).
/// L'écran n'a jamais à deviner d'où vient ce qu'il affiche.
class CachedData<T> {
  const CachedData({
    required this.value,
    required this.updatedAt,
    this.refreshError,
  });

  final T value;

  /// Dernière actualisation réussie, vide si la donnée n'a jamais été
  /// téléchargée.
  final DateTime? updatedAt;

  /// Erreur de la dernière tentative d'actualisation, vide si elle a réussi.
  final Object? refreshError;

  /// Peut-être ancienne : l'écran affiche alors la date et un bandeau.
  bool get isStale => refreshError != null;
}
