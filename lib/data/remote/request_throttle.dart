import 'dart:async';
import 'dart:collection';

import 'package:pecule/core/clock.dart';

enum RequestPriority {
  /// Une fiche ouverte, un achat : l'utilisateur attend la réponse.
  high,

  /// Le remplissage de l'Explorer en arrière-plan.
  low,
}

/// File d'attente qui respecte le quota d'une API : au plus [maxRequests]
/// requêtes lancées par [window] glissante (cahier des charges, section 5.3).
/// Une requête de trop attend son tour au lieu de provoquer une erreur de
/// quota.
class RequestThrottle {
  RequestThrottle({
    required this.maxRequests,
    required this.window,
    required this._clock,
    Future<void> Function(Duration delay)? wait,
  }) : _wait = wait ?? Future<void>.delayed;

  final int maxRequests;
  final Duration window;
  final Clock _clock;
  final Future<void> Function(Duration delay) _wait;

  final _startedAt = Queue<DateTime>();
  final _highPriority = Queue<Completer<void>>();
  final _lowPriority = Queue<Completer<void>>();
  var _isDispatching = false;

  Future<T> run<T>(
    Future<T> Function() request, {
    RequestPriority priority = RequestPriority.high,
  }) async {
    final turn = Completer<void>();
    switch (priority) {
      case RequestPriority.high:
        _highPriority.add(turn);
      case RequestPriority.low:
        _lowPriority.add(turn);
    }
    unawaited(_dispatch());
    await turn.future;
    return request();
  }

  // Une seule boucle de distribution à la fois : les appels suivants ne font
  // qu'ajouter leur tour dans la file.
  Future<void> _dispatch() async {
    if (_isDispatching) return;
    _isDispatching = true;
    while (_highPriority.isNotEmpty || _lowPriority.isNotEmpty) {
      final now = _clock.now();
      while (_startedAt.isNotEmpty &&
          now.difference(_startedAt.first) >= window) {
        _startedAt.removeFirst();
      }
      if (_startedAt.length >= maxRequests) {
        await _wait(window - now.difference(_startedAt.first));
        continue;
      }
      final next = _highPriority.isNotEmpty
          ? _highPriority.removeFirst()
          : _lowPriority.removeFirst();
      _startedAt.add(now);
      next.complete();
    }
    _isDispatching = false;
  }
}
