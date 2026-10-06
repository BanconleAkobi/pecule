import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/catalogue.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/currency.dart';

void main() {
  int countOf(AssetType type) =>
      catalogue.where((asset) => asset.type == type).length;

  test('contient dix actions, dix ETF et dix cryptos', () {
    expect(countOf(AssetType.stock), 10);
    expect(countOf(AssetType.etf), 10);
    expect(countOf(AssetType.crypto), 10);
  });

  test('n\'a aucun identifiant ni symbole en double', () {
    expect(catalogue.map((asset) => asset.id).toSet(), hasLength(30));
    expect(catalogue.map((asset) => asset.symbol).toSet(), hasLength(30));
  });

  test('est entièrement coté en dollars', () {
    expect(catalogue.every((asset) => asset.currency == Currency.usd), isTrue);
  });

  test('retrouve un actif par son identifiant', () {
    expect(catalogueById['bitcoin']?.symbol, 'BTC');
  });
}
