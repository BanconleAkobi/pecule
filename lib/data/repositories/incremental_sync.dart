import 'dart:developer' as developer;

import 'package:pecule/core/cached_data.dart';
import 'package:pecule/core/clock.dart';
import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/local/sync_state.dart';
import 'package:pecule/data/local/sync_state_dao.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/domain/calculations/trading_calendar.dart';

/// Ce qui change d'une série datée à l'autre (historique d'un actif, taux de
/// change). L'algorithme de mise à jour, lui, est commun : [IncrementalSync].
abstract interface class SyncedSeries<T> {
  /// Clé de la ressource dans `sync_state` : `asset:AAPL`, `fx:EUR:USD`.
  String get resourceKey;

  PublicationSchedule get schedule;

  /// Vrai quand la valeur du dernier jour reçu pouvait encore bouger (cours
  /// du jour d'une crypto) : ce jour-là est alors redemandé.
  bool get rewritesLastDay;

  DateTime firstDownloadStart(DateTime now);

  DateTime dayOf(T item);

  Future<List<T>> readCached();

  Future<List<T>> download({required DateTime since});

  Future<void> save(List<T> items);
}

/// Décide entre cache et réseau (cahier des charges, section 7.2). C'est le
/// seul endroit qui prend cette décision.
class IncrementalSync {
  IncrementalSync({required this._syncStates, required this._clock});

  static const freshnessDelay = Duration(hours: 6);

  final SyncStateDao _syncStates;
  final Clock _clock;

  /// Émet tout de suite ce qui est en base, puis la série complétée si un
  /// téléchargement était nécessaire. Une erreur réseau n'interrompt jamais le
  /// flux : elle accompagne les données disponibles, même vides.
  ///
  /// [forceRefresh] : tirer pour actualiser, qui ignore le délai de six heures.
  Stream<CachedData<List<T>>> watch<T>(
    SyncedSeries<T> series, {
    bool forceRefresh = false,
  }) async* {
    final cached = await series.readCached();
    final syncState = await _syncStates.find(series.resourceKey);
    if (cached.isNotEmpty) {
      yield CachedData(value: cached, updatedAt: syncState?.lastFetchedAt);
    }

    final now = _clock.now();
    if (!forceRefresh && _isRecent(syncState, now)) return;

    final expectedDay = expectedLatestDay(series.schedule, now: now);
    if (syncState != null && !syncState.lastDataDay.isBefore(expectedDay)) {
      await _saveSyncState(series.resourceKey, syncState.lastDataDay, now);
      yield CachedData(value: cached, updatedAt: now);
      return;
    }

    final since = _downloadStart(series, syncState, now);
    try {
      final downloaded = await series.download(since: since);
      await series.save(downloaded);
      // Sans aucune valeur ni en base ni dans la réponse, il n'y a pas encore
      // de dernier jour à retenir : on retentera au prochain affichage.
      final lastDataDay = downloaded.isNotEmpty
          ? series.dayOf(downloaded.last)
          : syncState?.lastDataDay;
      if (lastDataDay != null) {
        await _saveSyncState(series.resourceKey, lastDataDay, now);
      }
      developer.log(
        '${series.resourceKey} : ${downloaded.length} jours téléchargés '
        'depuis ${formatIsoDay(since)}',
        name: 'pecule.cache',
      );
      yield CachedData(value: await series.readCached(), updatedAt: now);
    } on ApiException catch (error) {
      yield CachedData(
        value: cached,
        updatedAt: syncState?.lastFetchedAt,
        refreshError: error,
      );
    }
  }

  bool _isRecent(SyncState? syncState, DateTime now) =>
      syncState != null &&
      now.difference(syncState.lastFetchedAt) < freshnessDelay;

  // Les jours passés ne changent plus : on ne demande que ceux qui manquent.
  DateTime _downloadStart(
    SyncedSeries<Object?> series,
    SyncState? syncState,
    DateTime now,
  ) {
    if (syncState == null) return series.firstDownloadStart(now);
    final lastDay = syncState.lastDataDay;
    if (series.rewritesLastDay) return lastDay;
    return DateTime.utc(lastDay.year, lastDay.month, lastDay.day + 1);
  }

  Future<void> _saveSyncState(
    String resourceKey,
    DateTime lastDataDay,
    DateTime now,
  ) {
    return _syncStates.save(
      SyncState(
        resourceKey: resourceKey,
        lastDataDay: lastDataDay,
        lastFetchedAt: now,
      ),
    );
  }
}
