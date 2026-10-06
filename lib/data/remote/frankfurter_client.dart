import 'package:http/http.dart' as http;
import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/remote/dto/frankfurter_dto.dart';
import 'package:pecule/data/remote/http_json.dart';

class FrankfurterClient {
  FrankfurterClient(this._client);

  static const _host = 'api.frankfurter.dev';

  final http.Client _client;

  /// Taux EUR/USD de [from] inclus jusqu'au dernier publié. Sans clé.
  Future<List<FrankfurterRateDto>> fetchEurUsdRates({
    required DateTime from,
  }) async {
    final uri = Uri.https(_host, '/v2/rates', {
      'from': formatIsoDay(from),
      'base': 'EUR',
      'quotes': 'USD',
    });
    final json = await getJson(_client, uri);
    return parseJson(
      json,
      (json) => [
        for (final rate in json! as List<dynamic>)
          FrankfurterRateDto.fromJson(rate as Map<String, dynamic>),
      ],
    );
  }
}
