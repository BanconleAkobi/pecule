import 'package:pecule/data/iso_day.dart';

class FrankfurterRateDto {
  const FrankfurterRateDto({
    required this.day,
    required this.base,
    required this.quote,
    required this.rate,
  });

  factory FrankfurterRateDto.fromJson(Map<String, dynamic> json) {
    return FrankfurterRateDto(
      day: parseIsoDay(json['date'] as String),
      base: json['base'] as String,
      quote: json['quote'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }

  final DateTime day;
  final String base;
  final String quote;
  final double rate;
}
