/// Erreurs des appels aux API, traduites depuis le paquet http et le contenu
/// des réponses. Le reste de l'application ne voit que celles-ci.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType : $message';
}

final class NetworkException extends ApiException {
  const NetworkException(super.message);
}

final class RateLimitException extends ApiException {
  const RateLimitException(super.message);
}

final class ApiErrorException extends ApiException {
  const ApiErrorException(this.code, String message) : super(message);

  final int code;
}

final class UnexpectedResponseException extends ApiException {
  const UnexpectedResponseException(super.message);
}
