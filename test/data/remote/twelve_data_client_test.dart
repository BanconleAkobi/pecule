import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/data/remote/twelve_data_client.dart';

import '../../helpers/fixtures.dart';

void main() {
  late http.Request lastRequest;

  TwelveDataClient clientAnswering(String body) {
    final httpClient = MockClient((request) async {
      lastRequest = request;
      return http.Response(body, 200);
    });
    return TwelveDataClient(httpClient, 'test-key');
  }

  final seriesFixture = readFixtureText('twelve_data_time_series_aapl.json');
  final startDay = DateTime.utc(2026, 9, 21);

  test(
    'demande les cours quotidiens d\'un symbole à partir d\'un jour',
    () async {
      await clientAnswering(seriesFixture)
          .fetchDailyBars('AAPL', startDay: startDay);

      expect(lastRequest.url.host, 'api.twelvedata.com');
      expect(lastRequest.url.path, '/time_series');
      expect(lastRequest.url.queryParameters, {
        'symbol': 'AAPL',
        'interval': '1day',
        'start_date': '2026-09-21',
        'order': 'asc',
        'outputsize': '5000',
      });
    },
  );

  test('envoie la clé en en-tête, jamais dans l\'adresse', () async {
    await clientAnswering(seriesFixture)
        .fetchDailyBars('AAPL', startDay: startDay);

    expect(lastRequest.headers['Authorization'], 'apikey test-key');
    expect(lastRequest.url.toString(), isNot(contains('test-key')));
  });

  test('renvoie les cours lus dans la réponse', () async {
    final bars = await clientAnswering(seriesFixture)
        .fetchDailyBars('AAPL', startDay: startDay);

    expect(bars, hasLength(9));
  });

  test(
    'renvoie une liste vide quand aucun cours n\'est encore publié',
    () async {
      final bars = await clientAnswering(
        readFixtureText('twelve_data_no_data.json'),
      ).fetchDailyBars('AAPL', startDay: DateTime.utc(2030, 1, 7));

      expect(bars, isEmpty);
    },
  );

  test('signale une erreur de l\'API avec son code', () {
    final client = clientAnswering(
      readFixtureText('twelve_data_error_unknown_symbol.json'),
    );

    expect(
      client.fetchDailyBars('PECULE_UNKNOWN', startDay: startDay),
      throwsA(
        isA<ApiErrorException>().having((error) => error.code, 'code', 404),
      ),
    );
  });

  test('traduit une erreur de quota annoncée dans le corps de la réponse', () {
    final client = clientAnswering(
      '{"code":429,"message":"You have run out of API credits","status":"error"}',
    );

    expect(
      client.fetchDailyBars('AAPL', startDay: startDay),
      throwsA(isA<RateLimitException>()),
    );
  });
}
