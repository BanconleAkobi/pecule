import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/data/remote/http_json.dart';

final anyUri = Uri.https('example.com', '/data');

MockClient answering(http.Response response) =>
    MockClient((_) async => response);

void main() {
  test('lit le JSON d\'une réponse réussie', () async {
    final json = await getJson(
      answering(http.Response('{"rate":1.1481}', 200)),
      anyUri,
    );

    expect(json, {'rate': 1.1481});
  });

  test(
    'décode les accents en UTF-8, même sans jeu de caractères annoncé',
    () async {
      final json = await getJson(
        answering(http.Response.bytes(utf8.encode('{"name":"Pécule"}'), 200)),
        anyUri,
      );

      expect(json, {'name': 'Pécule'});
    },
  );

  test('traduit une coupure réseau en NetworkException', () {
    final client = MockClient((_) => throw http.ClientException('hors ligne'));

    expect(getJson(client, anyUri), throwsA(isA<NetworkException>()));
  });

  test('traduit un statut 429 en RateLimitException', () {
    expect(
      getJson(answering(http.Response('', 429)), anyUri),
      throwsA(isA<RateLimitException>()),
    );
  });

  test('signale un autre statut d\'erreur avec son code', () {
    expect(
      getJson(answering(http.Response('', 503)), anyUri),
      throwsA(
        isA<ApiErrorException>().having((error) => error.code, 'code', 503),
      ),
    );
  });

  test('signale une réponse qui n\'est pas du JSON', () {
    expect(
      getJson(answering(http.Response('<html></html>', 200)), anyUri),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });

  test('signale une réponse dont la forme ne correspond pas au DTO', () {
    expect(
      () => parseJson({
        'rate': 1.1481,
      }, (json) => (json! as Map<String, dynamic>)['date'] as String),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });
}
