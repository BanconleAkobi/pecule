import 'package:http/http.dart' as http;
import 'package:pecule/data/remote/dto/coingecko_dto.dart';
import 'package:pecule/data/remote/http_json.dart';

class CoinGeckoClient {
  CoinGeckoClient(this._client, this._apiKey);

  static const _host = 'api.coingecko.com';

  final http.Client _client;
  final String _apiKey;

  Map<String, String> get _headers => {'x-cg-demo-api-key': _apiKey};

  /// Prix, capitalisation et volume quotidiens de [coinId] en dollars, de
  /// [from] à [to]. Le plan Demo ne remonte pas au-delà de 365 jours.
  Future<CoinGeckoMarketChartDto> fetchDailyChart(
    String coinId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final uri = Uri.https(_host, '/api/v3/coins/$coinId/market_chart/range', {
      'vs_currency': 'usd',
      'from': _unixSeconds(from),
      'to': _unixSeconds(to),
      'interval': 'daily',
    });
    final json = await getJson(_client, uri, headers: _headers);
    return parseJson(
      json,
      (json) => CoinGeckoMarketChartDto.fromJson(json! as Map<String, dynamic>),
    );
  }

  /// Cours actuel et variation sur un an de plusieurs cryptos en un appel.
  Future<List<CoinGeckoMarketDto>> fetchMarkets(List<String> coinIds) async {
    final uri = Uri.https(_host, '/api/v3/coins/markets', {
      'vs_currency': 'usd',
      'ids': coinIds.join(','),
      'price_change_percentage': '1y',
    });
    final json = await getJson(_client, uri, headers: _headers);
    return parseJson(
      json,
      (json) => [
        for (final market in json! as List<dynamic>)
          CoinGeckoMarketDto.fromJson(market as Map<String, dynamic>),
      ],
    );
  }

  String _unixSeconds(DateTime moment) =>
      (moment.millisecondsSinceEpoch ~/ 1000).toString();
}
