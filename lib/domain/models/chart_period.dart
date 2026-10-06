import 'package:pecule/domain/calculations/calendar.dart';

enum ChartPeriod {
  oneMonth(months: 1),
  sixMonths(months: 6),
  oneYear(months: 12),
  threeYears(months: 36),
  max(months: null);

  const ChartPeriod({required this.months});

  /// Vide pour [max] : tout l'historique.
  final int? months;

  /// Premier jour de la période : le même jour, [months] mois plus tôt.
  /// Vide pour [max].
  DateTime? startDay(DateTime today) {
    final months = this.months;
    if (months == null) return null;
    return addMonths(today, -months);
  }
}
