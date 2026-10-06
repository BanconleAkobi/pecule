import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pecule/data/remote/frankfurter_client.dart';

import '../../helpers/fixtures.dart';

void main() {
  late http.Request lastRequest;

  final client = FrankfurterClient(
    MockClient((request) async {
      lastRequest = request;
      return http.Response(
        readFixtureText('frankfurter_rates_eur_usd.json'),
        200,
      );
    }),
  );

  test(
    'demande les taux EUR/USD à partir d\'un jour, sans date de fin',
    () async {
      await client.fetchEurUsdRates(from: DateTime.utc(2026, 9, 21));

      expect(lastRequest.url.host, 'api.frankfurter.dev');
      expect(lastRequest.url.path, '/v2/rates');
      expect(lastRequest.url.queryParameters, {
        'from': '2026-09-21',
        'base': 'EUR',
        'quotes': 'USD',
      });
    },
  );

  test('renvoie les taux lus dans la réponse', () async {
    final rates = await client.fetchEurUsdRates(
      from: DateTime.utc(2026, 9, 21),
    );

    expect(rates, hasLength(12));
  });
}
