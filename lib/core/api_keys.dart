/// Clés injectées à la compilation : `flutter run --dart-define-from-file=env.json`.
/// Jamais écrites dans le code. Sans fichier, elles sont vides et les appels
/// échouent avec une erreur de l'API, sans planter l'application.
abstract final class ApiKeys {
  static const twelveData = String.fromEnvironment('TWELVE_DATA_API_KEY');
  static const coinGecko = String.fromEnvironment('COINGECKO_API_KEY');
}
