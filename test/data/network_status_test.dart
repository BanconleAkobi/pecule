import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/network_status.dart';
import 'package:pecule/data/remote/api_exceptions.dart';

void main() {
  late NetworkStatus status;

  setUp(() => status = NetworkStatus());
  tearDown(() => status.dispose());

  test('est en ligne au démarrage', () {
    expect(status.isOffline, isFalse);
  });

  test('une coupure réseau fait passer hors ligne', () {
    status.reportFailure(const NetworkException('hors ligne'));

    expect(status.isOffline, isTrue);
  });

  test('une erreur de quota ne fait pas passer hors ligne', () {
    status.reportFailure(const RateLimitException('quota atteint'));

    expect(status.isOffline, isFalse);
  });

  test('prévient seulement quand l\'état change', () async {
    final changes = <bool>[];
    final subscription = status.offlineChanges.listen(changes.add);

    status.reportFailure(const NetworkException('hors ligne'));
    status.reportFailure(const NetworkException('toujours hors ligne'));
    status.reportSuccess();
    await Future<void>.delayed(Duration.zero);

    expect(changes, [true, false]);
    await subscription.cancel();
  });
}
