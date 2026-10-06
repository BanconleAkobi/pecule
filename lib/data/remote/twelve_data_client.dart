import 'package:http/http.dart' as http;
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/data/remote/dto/json_dates.dart';
import 'package:pecule/data/remote/dto/twelve_data_dto.dart';
import 'package:pecule/data/remote/http_json.dart';

class TwelveDataClient {
  TwelveDataClient(this._client, this._apiKey);

  static const _host = 'api.twelvedata.com';
  static const _rateLimitCode = 429;
  static const _maxOutputSize = '5000';

  final http.Client _client;
  final String _apiKey;

  /// Cours quotidiens de [symbol] à partir de [startDay] inclus, jusqu'au
  /// dernier publié. Liste vide s'il n'y a rien de nouveau. Coûte 1 crédit.
  Future<List<TwelveDataBarDto>> fetchDailyBars(
    String symbol, {
    required DateTime startDay,
  }) async {
    // Pas de end_date : Twelve Data exclut ce jour-là de la réponse.
    final uri = Uri.https(_host, '/time_series', {
      'symbol': symbol,
      'interval': '1day',
      'start_date': formatApiDay(startDay),
      'order': 'asc',
      'outputsize': _maxOutputSize,
    });
    final json = await getJson(
      _client,
      uri,
      headers: {'Authorization': 'apikey $_apiKey'},
    );

    return parseJson(json, (json) {
      final body = json! as Map<String, dynamic>;
      if (!TwelveDataErrorDto.isError(body)) {
        return TwelveDataTimeSeriesDto.fromJson(body).bars;
      }

      final error = TwelveDataErrorDto.fromJson(body);
      // Twelve Data répond par une erreur quand aucun cours n'existe depuis
      // startDay. Pour Pécule, c'est simplement « rien de nouveau ».
      if (error.isNoDataForDates) return const <TwelveDataBarDto>[];
      throw _exceptionFor(error);
    });
  }

  ApiException _exceptionFor(TwelveDataErrorDto error) {
    if (error.code == _rateLimitCode) return RateLimitException(error.message);
    return ApiErrorException(error.code, error.message);
  }
}
