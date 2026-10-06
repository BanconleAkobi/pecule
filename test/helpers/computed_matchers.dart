import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/computed.dart';

Matcher isAvailableCloseTo(double expected, {double delta = 1e-9}) {
  return isA<Available<double>>().having(
    (result) => result.value,
    'value',
    closeTo(expected, delta),
  );
}

Matcher isUnavailableBecause(UnavailableReason reason) {
  return isA<Unavailable<Object?>>().having(
    (result) => result.reason,
    'reason',
    reason,
  );
}
