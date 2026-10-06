import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/remote/request_throttle.dart';

import '../../helpers/fixed_clock.dart';

void main() {
  late FixedClock clock;
  late List<Duration> waits;
  late RequestThrottle throttle;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 10));
    waits = [];
    // Attendre ne prend aucun temps réel : l'horloge avance d'autant.
    throttle = RequestThrottle(
      maxRequests: 8,
      window: const Duration(minutes: 1),
      clock: clock,
      wait: (delay) async {
        waits.add(delay);
        clock.current = clock.current.add(delay);
      },
    );
  });

  Future<List<int>> runRequests(int count) {
    return Future.wait([
      for (var index = 0; index < count; index++)
        throttle.run(() async => index),
    ]);
  }

  test('laisse passer huit requêtes dans la minute sans attendre', () async {
    await runRequests(8);

    expect(waits, isEmpty);
  });

  test('fait attendre la neuvième jusqu\'à la fin de la minute', () async {
    await runRequests(9);

    expect(waits, [const Duration(minutes: 1)]);
  });

  test(
    'n\'attend que le temps restant avant la sortie de la plus ancienne',
    () async {
      await runRequests(8);
      clock.current = clock.current.add(const Duration(seconds: 45));

      await runRequests(1);

      expect(waits, [const Duration(seconds: 15)]);
    },
  );

  test('renvoie la réponse de chaque requête', () async {
    expect(await runRequests(3), [0, 1, 2]);
  });

  test('fait passer une requête prioritaire avant l\'arrière-plan', () async {
    await runRequests(8);
    final order = <String>[];

    await Future.wait([
      throttle.run(
        () async => order.add('Explorer 1'),
        priority: RequestPriority.low,
      ),
      throttle.run(
        () async => order.add('Explorer 2'),
        priority: RequestPriority.low,
      ),
      throttle.run(() async => order.add('fiche ouverte')),
    ]);

    expect(order, ['fiche ouverte', 'Explorer 1', 'Explorer 2']);
  });
}
