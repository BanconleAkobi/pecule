import 'package:pecule/domain/models/currency.dart';

class FxRate {
  const FxRate({
    required this.day,
    required this.base,
    required this.quote,
    required this.rate,
  });

  final DateTime day;
  final Currency base;
  final Currency quote;

  /// Unités de [quote] pour une unité de [base] : 1 € = 1,0952 $.
  final double rate;
}
