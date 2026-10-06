/// Source de l'heure. Injectée partout où le code a besoin de « maintenant »,
/// pour que les tests puissent la figer.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
