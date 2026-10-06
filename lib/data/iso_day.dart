/// Les API et la base stockent les jours sans heure (« 2026-09-21 ») : on les
/// lit à minuit UTC, la convention de Pécule pour un jour de cotation.
DateTime parseIsoDay(String text) {
  final date = DateTime.parse(text);
  return DateTime.utc(date.year, date.month, date.day);
}

String formatIsoDay(DateTime day) => day.toIso8601String().substring(0, 10);
