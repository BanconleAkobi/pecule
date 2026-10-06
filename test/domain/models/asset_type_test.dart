import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/models/asset_type.dart';

void main() {
  test('une action cote 252 jours par an', () {
    expect(AssetType.stock.tradingDaysPerYear, 252);
  });

  test('un ETF cote 252 jours par an', () {
    expect(AssetType.etf.tradingDaysPerYear, 252);
  });

  test('une crypto cote 365 jours par an', () {
    expect(AssetType.crypto.tradingDaysPerYear, 365);
  });
}
