import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pecule/data/remote/api_exceptions.dart';

const _timeout = Duration(seconds: 15);
const _tooManyRequests = 429;
const _ok = 200;

Future<Object?> getJson(
  http.Client client,
  Uri uri, {
  Map<String, String> headers = const {},
}) async {
  final http.Response response;
  try {
    response = await client.get(uri, headers: headers).timeout(_timeout);
  } on http.ClientException catch (error) {
    throw NetworkException(error.message);
  } on TimeoutException {
    throw const NetworkException('pas de réponse dans le délai');
  }

  if (response.statusCode == _tooManyRequests) {
    throw const RateLimitException('quota de requêtes atteint');
  }
  if (response.statusCode != _ok) {
    throw ApiErrorException(response.statusCode, response.reasonPhrase ?? '');
  }

  // Décodage explicite en UTF-8 : sans en-tête de jeu de caractères, `body`
  // lirait du latin-1 et abîmerait les accents.
  try {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } on FormatException {
    throw const UnexpectedResponseException('la réponse n\'est pas du JSON');
  }
}

// Si une API change la forme de ses réponses, les conversions de type des DTO
// échouent : on le signale comme une réponse inattendue plutôt que de planter.
T parseJson<T>(Object? json, T Function(Object? json) parse) {
  try {
    return parse(json);
  } on TypeError {
    throw const UnexpectedResponseException('forme de réponse inattendue');
  }
}
