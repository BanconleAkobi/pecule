import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/local/price_bar_dao.dart';
import 'package:pecule/data/remote/price_source.dart';
import 'package:pecule/data/remote/request_throttle.dart';
import 'package:pecule/data/repositories/incremental_sync.dart';
import 'package:pecule/domain/calculations/trading_calendar.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/price_bar.dart';

class PriceHistoryRepository {
  PriceHistoryRepository({
    required this._priceBars,
    required this._source,
    required this._sync,
  });

  static final stockHistoryStart = DateTime.utc(2020, 1, 1);

  // Le plan Demo de CoinGecko ne remonte pas au-delà de 365 jours.
  static const cryptoHistoryDepth = Duration(days: 364);

  final PriceBarDao _priceBars;
  final PriceSource _source;
  final IncrementalSync _sync;

  /// [forceRefresh] : tirer pour actualiser, qui ignore le délai de six heures.
  /// [priority] : basse pour le remplissage de l'Explorer en arrière-plan.
  Stream<CachedData<List<PriceBar>>> watchHistory(
    Asset asset, {
    bool forceRefresh = false,
    RequestPriority priority = RequestPriority.high,
  }) {
    return _sync.watch(
      _AssetHistory(
        asset,
        priceBars: _priceBars,
        source: _source,
        priority: priority,
      ),
      forceRefresh: forceRefresh,
    );
  }
}

class _AssetHistory implements SyncedSeries<PriceBar> {
  _AssetHistory(
    this.asset, {
    required this.priceBars,
    required this.source,
    required this.priority,
  });

  final Asset asset;
  final PriceBarDao priceBars;
  final PriceSource source;
  final RequestPriority priority;

  @override
  String get resourceKey => 'asset:${asset.id}';

  @override
  PublicationSchedule get schedule => scheduleFor(asset.type);

  @override
  bool get rewritesLastDay => asset.type == AssetType.crypto;

  @override
  DateTime firstDownloadStart(DateTime now) {
    return switch (asset.type) {
      AssetType.stock ||
      AssetType.etf => PriceHistoryRepository.stockHistoryStart,
      AssetType.crypto => _dayOf(
        now.subtract(PriceHistoryRepository.cryptoHistoryDepth),
      ),
    };
  }

  @override
  DateTime dayOf(PriceBar item) => item.day;

  @override
  Future<List<PriceBar>> readCached() => priceBars.findBars(asset.id);

  @override
  Future<List<PriceBar>> download({required DateTime since}) =>
      source.fetchDailyBars(asset, since: since, priority: priority);

  @override
  Future<void> save(List<PriceBar> items) =>
      priceBars.saveBars(asset.id, items);

  DateTime _dayOf(DateTime moment) =>
      DateTime.utc(moment.year, moment.month, moment.day);
}
