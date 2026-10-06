import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/core/cached_data.dart';
import 'package:pecule/data/remote/api_exceptions.dart';

void main() {
  test('une donnée actualisée sans erreur n\'est pas ancienne', () {
    final data = CachedData(value: 42, updatedAt: DateTime.utc(2026, 10, 6));

    expect(data.isStale, isFalse);
  });

  test('une donnée dont l\'actualisation a échoué est peut-être ancienne', () {
    final data = CachedData(
      value: 42,
      updatedAt: DateTime.utc(2026, 10, 4),
      refreshError: const NetworkException('hors ligne'),
    );

    expect(data.isStale, isTrue);
  });
}
