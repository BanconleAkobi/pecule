import 'package:pecule/core/clock.dart';
import 'package:pecule/data/remote/coingecko_client.dart';
import 'package:pecule/data/remote/dto/coingecko_dto.dart';
import 'package:pecule/data/remote/dto/twelve_data_dto.dart';
import 'package:pecule/data/remote/request_throttle.dart';
import 'package:pecule/data/remote/twelve_data_client.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/price_bar.dart';

abstract interface class PriceSource {
  /// Cours quotidiens de [asset] à partir de [since] inclus.
  Future<List<PriceBar>> fetchDailyBars(
    Asset asset, {
    required DateTime since,
    required RequestPriority priority,
  });
}

/// L'identifiant d'un actif du catalogue est celui de son fournisseur :
/// le symbole Twelve Data (`AAPL`) ou l'identifiant CoinGecko (`bitcoin`).
class RemotePriceSource implements PriceSource {
  RemotePriceSource({
    required this._twelveData,
    required this._twelveDataThrottle,
    required this._coinGecko,
    required this._clock,
  });

  final TwelveDataClient _twelveData;
  final RequestThrottle _twelveDataThrottle;
  final CoinGeckoClient _coinGecko;
  final Clock _clock;

  /// Seules les requêtes Twelve Data passent par la file d'attente : c'est le
  /// quota serré (8 par minute). [priority] est ignorée pour CoinGecko.
  @override
  Future<List<PriceBar>> fetchDailyBars(
    Asset asset, {
    required DateTime since,
    required RequestPriority priority,
  }) async {
    switch (asset.type) {
      case AssetType.stock || AssetType.etf:
        final bars = await _twelveDataThrottle.run(
          () => _twelveData.fetchDailyBars(asset.id, startDay: since),
          priority: priority,
        );
        return bars.map(_fromTwelveData).toList();
      case AssetType.crypto:
        final chart = await _coinGecko.fetchDailyChart(
          asset.id,
          from: since,
          to: _clock.now(),
        );
        return _fromCoinGecko(chart);
    }
  }

  PriceBar _fromTwelveData(TwelveDataBarDto bar) => PriceBar(
    day: bar.day,
    open: bar.open,
    high: bar.high,
    low: bar.low,
    close: bar.close,
    volume: bar.volume,
  );

  // CoinGecko renvoie trois listes séparées (prix, capitalisation, volume) ;
  // on les réunit par jour.
  List<PriceBar> _fromCoinGecko(CoinGeckoMarketChartDto chart) {
    final marketCapByDay = {
      for (final point in chart.marketCaps) point.day: point.value,
    };
    final volumeByDay = {
      for (final point in chart.totalVolumes) point.day: point.value,
    };
    return [
      for (final price in chart.prices)
        PriceBar(
          day: price.day,
          close: price.value,
          volume: volumeByDay[price.day] ?? 0,
          marketCap: marketCapByDay[price.day],
        ),
    ];
  }
}
