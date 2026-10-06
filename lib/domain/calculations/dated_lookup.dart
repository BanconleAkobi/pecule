import 'package:pecule/domain/computed.dart';

/// Dernier élément de [series] daté au plus tard de [day]. Sert pour les jours
/// sans cotation ou sans taux (cahier des charges, section 8.1).
///
/// [series] doit être triée par jour croissant.
Computed<T> findLastOnOrBefore<T>(
  List<T> series,
  DateTime day, {
  required DateTime Function(T item) dayOf,
}) {
  for (final item in series.reversed) {
    if (!dayOf(item).isAfter(day)) return Available(item);
  }
  return const Unavailable(UnavailableReason.noDataForDate);
}
