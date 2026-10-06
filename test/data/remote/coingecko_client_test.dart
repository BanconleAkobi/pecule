import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pecule/data/remote/coingecko_client.dart';

import '../../helpers/fixtures.dart';

void main() {
  late http.Request lastRequest;

  CoinGeckoClient clientAnswering(String body) {
    final httpClient = MockClient((request) async {
      lastRequest = request;
      return http.Response(body, 200);
    });
    return CoinGeckoClient(httpClient, 'test-key');
  }

  group('historique', () {
    final chartFixture = readFixtureText(
      'coingecko_market_chart_range_bitcoin.json',
    );

    Future<void> fetchBitcoinChart() => clientAnswering(chartFixture)
        .fetchDailyChart(
          'bitcoin',
          from: DateTime.utc(2026, 9, 21),
          to: DateTime.utc(2026, 10, 3),
        );

    test('demande des points quotidiens en dollars entre deux jours', () async {
      await fetchBitcoinChart();

      expect(lastRequest.url.host, 'api.coingecko.com');
      expect(lastRequest.url.path, '/api/v3/coins/bitcoin/market_chart/range');
      expect(lastRequest.url.queryParameters, {
        'vs_currency': 'usd',
        'from': '1789948800',
        'to': '1790985600',
        'interval': 'daily',
      });
    });

    test('envoie la clé Demo en en-tête', () async {
      await fetchBitcoinChart();

      expect(lastRequest.headers['x-cg-demo-api-key'], 'test-key');
    });

    test('renvoie l\'historique lu dans la réponse', () async {
      final chart = await clientAnswering(chartFixture).fetchDailyChart(
        'bitcoin',
        from: DateTime.utc(2026, 9, 21),
        to: DateTime.utc(2026, 10, 3),
      );

      expect(chart.prices, hasLength(13));
    });
  });

  group('cours actuels', () {
    final marketsFixture = readFixtureText('coingecko_markets.json');

    test(
      'demande plusieurs cryptos et leur variation sur un an en un appel',
      () async {
        await clientAnswering(marketsFixture)
            .fetchMarkets(['bitcoin', 'ethereum']);

        expect(lastRequest.url.path, '/api/v3/coins/markets');
        expect(lastRequest.url.queryParameters, {
          'vs_currency': 'usd',
          'ids': 'bitcoin,ethereum',
          'price_change_percentage': '1y',
        });
      },
    );

    test('renvoie les cours lus dans la réponse', () async {
      final markets = await clientAnswering(marketsFixture)
          .fetchMarkets(['bitcoin', 'ethereum']);

      expect(markets.map((market) => market.id), ['bitcoin', 'ethereum']);
    });
  });
}
