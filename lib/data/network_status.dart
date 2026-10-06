import 'dart:async';

import 'package:pecule/data/remote/api_exceptions.dart';

/// État de la connexion, déduit des appels réseau : hors ligne dès qu'un appel
/// échoue faute de réseau, en ligne dès qu'un appel réussit. Sert au bandeau
/// « Hors connexion » (cahier des charges, section 7.4).
class NetworkStatus {
  final _changes = StreamController<bool>.broadcast();
  var _isOffline = false;

  bool get isOffline => _isOffline;

  /// Émet `true` au passage hors ligne, `false` au retour en ligne.
  Stream<bool> get offlineChanges => _changes.stream;

  void reportSuccess() => _update(isOffline: false);

  // Une erreur de quota ou de l'API ne dit rien du réseau : il fonctionne.
  void reportFailure(ApiException error) {
    if (error is NetworkException) _update(isOffline: true);
  }

  Future<void> dispose() => _changes.close();

  void _update({required bool isOffline}) {
    if (isOffline == _isOffline) return;
    _isOffline = isOffline;
    _changes.add(isOffline);
  }
}
