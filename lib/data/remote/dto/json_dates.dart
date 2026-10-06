/// Les API donnent les jours sans heure (« 2026-09-21 ») : on les place à
/// minuit UTC, la convention de Pécule pour un jour de cotation.
DateTime parseDay(String text) {
  final date = DateTime.parse(text);
  return DateTime.utc(date.year, date.month, date.day);
}

/// Jour au format attendu par les API : « 2026-09-21 ».
String formatApiDay(DateTime day) => day.toIso8601String().substring(0, 10);
