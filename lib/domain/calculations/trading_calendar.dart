import 'package:pecule/domain/models/asset_type.dart';

/// Rythme de publication d'une source de cours.
class PublicationSchedule {
  const PublicationSchedule({
    required this.publishesOnWeekends,
    required this.publicationHourUtc,
  });

  final bool publishesOnWeekends;

  /// Heure UTC à partir de laquelle la valeur du jour est disponible.
  final int publicationHourUtc;
}

// La bourse de New York ferme à 16 h, soit 20 h ou 21 h UTC selon l'heure
// d'été : 22 h laisse une heure de marge.
const stockMarketSchedule = PublicationSchedule(
  publishesOnWeekends: false,
  publicationHourUtc: 22,
);

const cryptoMarketSchedule = PublicationSchedule(
  publishesOnWeekends: true,
  publicationHourUtc: 0,
);

const fxRatesSchedule = PublicationSchedule(
  publishesOnWeekends: true,
  publicationHourUtc: 16,
);

PublicationSchedule scheduleFor(AssetType type) => switch (type) {
  AssetType.stock || AssetType.etf => stockMarketSchedule,
  AssetType.crypto => cryptoMarketSchedule,
};

/// Jour le plus récent dont la valeur devrait déjà être publiée à [now].
/// Si le cache l'a déjà, inutile d'appeler l'API (cahier des charges,
/// section 7.2). Les jours fériés ne sont pas connus : l'API répond alors
/// « rien de nouveau ».
DateTime expectedLatestDay(
  PublicationSchedule schedule, {
  required DateTime now,
}) {
  final utcNow = now.toUtc();
  var day = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);
  if (utcNow.hour < schedule.publicationHourUtc) {
    day = _previousDay(day);
  }
  while (!schedule.publishesOnWeekends && _isWeekend(day)) {
    day = _previousDay(day);
  }
  return day;
}

DateTime _previousDay(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day - 1);

bool _isWeekend(DateTime day) =>
    day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
