import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/calendar.dart';

void main() {
  test('garde le même jour du mois', () {
    expect(addMonths(DateTime.utc(2026, 1, 15), 1), DateTime.utc(2026, 2, 15));
  });

  test('prend le dernier jour d\'un mois plus court', () {
    expect(addMonths(DateTime.utc(2026, 1, 31), 1), DateTime.utc(2026, 2, 28));
  });

  test('recule aussi d\'un mois, jusque dans l\'année précédente', () {
    expect(
      addMonths(DateTime.utc(2026, 1, 15), -1),
      DateTime.utc(2025, 12, 15),
    );
  });

  test('connaît le 29 février des années bissextiles', () {
    expect(addMonths(DateTime.utc(2028, 3, 31), -1), DateTime.utc(2028, 2, 29));
  });
}
