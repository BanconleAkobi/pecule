import 'dart:developer' as developer;

import 'package:pecule/core/cached_data.dart';
import 'package:pecule/core/clock.dart';
import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/local/price_bar_dao.dart';
import 'package:pecule/data/local/sync_state.dart';
import 'package:pecule/data/local/sync_state_dao.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/data/remote/price_source.dart';
import 'package:pecule/domain/calculations/trading_calendar.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/price_bar.dart';

/// Décide entre cache et réseau pour l'historique d'un actif (cahier des
/// charges, section 7.2). C'est le seul endroit qui prend cette décision.
class PriceHistoryRepository {
  PriceHistoryRepository({
    required this._priceBars,
    required this._syncStates,
    required this._source,
    required this._clock,
  });

  static const freshnessDelay = Duration(hours: 6);
  static final stockHistoryStart = DateTime.utc(2020, 1, 1);

  // Le plan Demo de CoinGecko ne remonte pas au-delà de 365 jours.
  static const cryptoHistoryDepth = Duration(days: 364);

  final PriceBarDao _priceBars;
  final SyncStateDao _syncStates;
  final PriceSource _source;
  final Clock _clock;

  /// Émet tout de suite ce qui est en base, puis l'historique complété si un
  /// téléchargement était nécessaire. Une erreur réseau n'interrompt jamais le
  /// flux : elle accompagne les données disponibles, même vides.
  ///
  /// [forceRefresh] : tirer pour actualiser, qui ignore le délai de six heures.
  Stream<CachedData<List<PriceBar>>> watchHistory(
    Asset asset, {
    bool forceRefresh = false,
  }) async* {
    final resourceKey = 'asset:${asset.id}';
    final cached = await _priceBars.findBars(asset.id);
    final syncState = await _syncStates.find(resourceKey);
    if (cached.isNotEmpty) {
      yield CachedData(value: cached, updatedAt: syncState?.lastFetchedAt);
    }

    final now = _clock.now();
    if (!forceRefresh && _isRecent(syncState, now)) return;

    final expectedDay = expectedLatestDay(scheduleFor(asset.type), now: now);
    if (syncState != null && !syncState.lastDataDay.isBefore(expectedDay)) {
      await _markFetched(syncState, now);
      yield CachedData(value: cached, updatedAt: now);
      return;
    }

    final since = _downloadStart(asset, syncState, now);
    try {
      final downloaded = await _source.fetchDailyBars(asset, since: since);
      await _priceBars.saveBars(asset.id, downloaded);
      await _saveSyncState(resourceKey, syncState, downloaded, now);
      developer.log(
        '$resourceKey : ${downloaded.length} jours téléchargés depuis '
        '${formatIsoDay(since)}',
        name: 'pecule.cache',
      );
      yield CachedData(
        value: await _priceBars.findBars(asset.id),
        updatedAt: now,
      );
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
  // Pour une crypto, le dernier jour reçu est redemandé : son cours bougeait
  // encore au moment du téléchargement.
  DateTime _downloadStart(Asset asset, SyncState? syncState, DateTime now) {
    if (syncState == null) {
      return switch (asset.type) {
        AssetType.stock || AssetType.etf => stockHistoryStart,
        AssetType.crypto => _dayOf(now.subtract(cryptoHistoryDepth)),
      };
    }
    final lastDay = syncState.lastDataDay;
    return switch (asset.type) {
      AssetType.stock || AssetType.etf => DateTime.utc(
        lastDay.year,
        lastDay.month,
        lastDay.day + 1,
      ),
      AssetType.crypto => lastDay,
    };
  }

  Future<void> _markFetched(SyncState syncState, DateTime now) {
    return _syncStates.save(
      SyncState(
        resourceKey: syncState.resourceKey,
        lastDataDay: syncState.lastDataDay,
        lastFetchedAt: now,
      ),
    );
  }

  // Sans aucun cours ni en base ni dans la réponse, il n'y a pas encore de
  // dernier jour à retenir : on retentera au prochain affichage.
  Future<void> _saveSyncState(
    String resourceKey,
    SyncState? previous,
    List<PriceBar> downloaded,
    DateTime now,
  ) async {
    final lastDataDay = downloaded.isNotEmpty
        ? downloaded.last.day
        : previous?.lastDataDay;
    if (lastDataDay == null) return;
    await _syncStates.save(
      SyncState(
        resourceKey: resourceKey,
        lastDataDay: lastDataDay,
        lastFetchedAt: now,
      ),
    );
  }

  DateTime _dayOf(DateTime moment) =>
      DateTime.utc(moment.year, moment.month, moment.day);
}
