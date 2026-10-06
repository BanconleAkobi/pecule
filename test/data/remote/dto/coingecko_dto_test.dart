import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/remote/dto/coingecko_dto.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('historique d\'une crypto', () {
    final chart = CoinGeckoMarketChartDto.fromJson(
      readJsonObjectFixture('coingecko_market_chart_range_bitcoin.json'),
    );

    test('lit un prix par jour, daté à minuit UTC', () {
      expect(chart.prices, hasLength(13));
      expect(chart.prices.first.day, DateTime.utc(2026, 9, 21));
      expect(chart.prices.last.day, DateTime.utc(2026, 10, 3));
    });

    test('lit la valeur de chaque prix', () {
      expect(chart.prices.first.value, closeTo(81169.035, 1e-3));
    });

    test('lit la capitalisation et le volume de chaque jour', () {
      expect(chart.marketCaps, hasLength(13));
      expect(chart.totalVolumes, hasLength(13));
      expect(chart.marketCaps.first.value, closeTo(1630456856533.65, 1e-2));
    });
  });

  group('cours actuels', () {
    final markets = readJsonListFixture(
      'coingecko_markets.json',
    ).map((json) => CoinGeckoMarketDto.fromJson(json as Map<String, dynamic>));

    test('lit l\'identifiant et le cours actuel, même donné en entier', () {
      final bitcoin = markets.first;

      expect(bitcoin.id, 'bitcoin');
      expect(bitcoin.currentPrice, 86253);
    });

    test('lit la variation sur un an, donnée en pourcentage', () {
      expect(markets.first.priceChangePercentage1y, closeTo(-30.3834, 1e-9));
    });

    test('lit la date de dernière mise à jour en UTC', () {
      expect(markets.first.lastUpdated, DateTime.utc(2026, 10, 6, 12, 0, 30));
    });
  });
}
