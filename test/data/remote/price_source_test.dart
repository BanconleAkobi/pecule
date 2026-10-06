import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pecule/data/remote/coingecko_client.dart';
import 'package:pecule/data/remote/price_source.dart';
import 'package:pecule/data/remote/request_throttle.dart';
import 'package:pecule/data/remote/twelve_data_client.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/price_bar.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_assets.dart';

void main() {
  late http.Request lastRequest;

  http.Client answering(String fixture) => MockClient((request) async {
    lastRequest = request;
    return http.Response(readFixtureText(fixture), 200);
  });

  final now = DateTime.utc(2026, 10, 3);
  final clock = FixedClock(now);

  final source = RemotePriceSource(
    twelveData: TwelveDataClient(
      answering('twelve_data_time_series_aapl.json'),
      'test-key',
    ),
    twelveDataThrottle: RequestThrottle(
      maxRequests: 8,
      window: const Duration(minutes: 1),
      clock: clock,
    ),
    coinGecko: CoinGeckoClient(
      answering('coingecko_market_chart_range_bitcoin.json'),
      'test-key',
    ),
    clock: clock,
  );

  Future<List<PriceBar>> fetchSinceSeptember21(Asset asset) =>
      source.fetchDailyBars(
        asset,
        since: DateTime.utc(2026, 9, 21),
        priority: RequestPriority.high,
      );

  test('récupère une action chez Twelve Data avec ouverture, plus haut et plus bas', () async {
    final bars = await fetchSinceSeptember21(apple);

    expect(bars, hasLength(9));
    expect(bars.first.day, DateTime.utc(2026, 9, 21));
    expect(bars.first.open, 335.28);
    expect(bars.first.close, 338.98001);
    expect(bars.first.volume, 34999200);
  });

  test(
    'récupère une crypto chez CoinGecko avec sa capitalisation et son volume',
    () async {
      final bars = await fetchSinceSeptember21(bitcoin);

      expect(bars, hasLength(13));
      expect(bars.first.close, closeTo(81169.035, 1e-3));
      expect(bars.first.marketCap, closeTo(1630456856533.65, 1e-2));
      expect(bars.first.volume, closeTo(23789617808.47, 1e-2));
      expect(bars.first.open, isNull);
    },
  );

  test('demande à CoinGecko les cours jusqu\'à maintenant', () async {
    await fetchSinceSeptember21(bitcoin);

    final nowInSeconds = now.millisecondsSinceEpoch ~/ 1000;
    expect(lastRequest.url.queryParameters['to'], '$nowInSeconds');
  });
}
