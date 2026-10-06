import 'package:pecule/data/remote/dto/json_dates.dart';

class TwelveDataTimeSeriesDto {
  const TwelveDataTimeSeriesDto({
    required this.symbol,
    required this.currency,
    required this.bars,
  });

  factory TwelveDataTimeSeriesDto.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    final values = json['values'] as List<dynamic>;
    return TwelveDataTimeSeriesDto(
      symbol: meta['symbol'] as String,
      currency: meta['currency'] as String,
      bars: [
        for (final value in values)
          TwelveDataBarDto.fromJson(value as Map<String, dynamic>),
      ],
    );
  }

  final String symbol;
  final String currency;
  final List<TwelveDataBarDto> bars;
}

class TwelveDataBarDto {
  const TwelveDataBarDto({
    required this.day,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  // Twelve Data donne les prix et le volume en texte : « "338.98001" ».
  factory TwelveDataBarDto.fromJson(Map<String, dynamic> json) {
    return TwelveDataBarDto(
      day: parseDay(json['datetime'] as String),
      open: double.parse(json['open'] as String),
      high: double.parse(json['high'] as String),
      low: double.parse(json['low'] as String),
      close: double.parse(json['close'] as String),
      volume: double.parse(json['volume'] as String),
    );
  }

  final DateTime day;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
}

/// Twelve Data signale ses erreurs dans le corps de la réponse, avec
/// `"status": "error"` et un code : 429 quand le quota est atteint.
class TwelveDataErrorDto {
  const TwelveDataErrorDto({required this.code, required this.message});

  factory TwelveDataErrorDto.fromJson(Map<String, dynamic> json) {
    return TwelveDataErrorDto(
      code: json['code'] as int,
      message: json['message'] as String,
    );
  }

  static bool isError(Map<String, dynamic> json) => json['status'] == 'error';

  static const _badRequestCode = 400;
  static const _noDataMessageStart = 'No data is available';

  final int code;
  final String message;

  // Seul moyen de reconnaître ce cas : le code 400 sert aussi à d'autres
  // erreurs, c'est le début du message qui le distingue.
  bool get isNoDataForDates =>
      code == _badRequestCode && message.startsWith(_noDataMessageStart);
}
