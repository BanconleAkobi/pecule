import 'dart:math' as math;

/// Même jour, [months] mois plus tard (ou plus tôt si négatif). Quand ce jour
/// n'existe pas, on prend le dernier du mois : le 31 janvier plus un mois
/// donne le 28 février, pas le 3 mars.
DateTime addMonths(DateTime day, int months) {
  final targetMonth = DateTime.utc(day.year, day.month + months);
  final lastDayOfMonth = DateTime.utc(
    targetMonth.year,
    targetMonth.month + 1,
    0,
  ).day;
  return DateTime.utc(
    targetMonth.year,
    targetMonth.month,
    math.min(day.day, lastDayOfMonth),
  );
}
