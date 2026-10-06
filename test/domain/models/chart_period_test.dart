import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/models/chart_period.dart';

void main() {
  final today = DateTime.utc(2026, 10, 7);

  test('un mois commence le même jour du mois précédent', () {
    expect(ChartPeriod.oneMonth.startDay(today), DateTime.utc(2026, 9, 7));
  });

  test('un an commence le même jour de l\'année précédente', () {
    expect(ChartPeriod.oneYear.startDay(today), DateTime.utc(2025, 10, 7));
  });

  test('trois ans commencent le même jour, trois ans plus tôt', () {
    expect(ChartPeriod.threeYears.startDay(today), DateTime.utc(2023, 10, 7));
  });

  test('« Max » n\'a pas de premier jour : tout l\'historique', () {
    expect(ChartPeriod.max.startDay(today), isNull);
  });
}
