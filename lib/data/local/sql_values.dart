// SQLite renvoie parfois un entier pour une colonne REAL dont la valeur est
// ronde : on passe par num pour toujours obtenir un double.
double readDouble(Object? value) => (value! as num).toDouble();

double? readNullableDouble(Object? value) => (value as num?)?.toDouble();

int toMillis(DateTime moment) => moment.toUtc().millisecondsSinceEpoch;

DateTime fromMillis(Object? value) =>
    DateTime.fromMillisecondsSinceEpoch(value! as int, isUtc: true);
