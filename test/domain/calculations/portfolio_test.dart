import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/calculations/portfolio.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/concentration_advice.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/paper_transaction.dart';
import 'package:pecule/domain/models/position.dart';
import 'package:pecule/domain/models/valued_portfolio.dart';

import '../../helpers/computed_matchers.dart';

const apple = Asset(
  id: 'AAPL',
  name: 'Apple',
  symbol: 'AAPL',
  type: AssetType.stock,
  currency: Currency.usd,
);
const spy = Asset(
  id: 'SPY',
  name: 'SPDR S&P 500',
  symbol: 'SPY',
  type: AssetType.etf,
  currency: Currency.usd,
);
const bitcoin = Asset(
  id: 'bitcoin',
  name: 'Bitcoin',
  symbol: 'BTC',
  type: AssetType.crypto,
  currency: Currency.usd,
);
const catalogue = {'AAPL': apple, 'SPY': spy, 'bitcoin': bitcoin};

PaperTransaction purchase(
  Asset asset, {
  required double quantity,
  required double amountEur,
}) {
  return PaperTransaction(
    assetId: asset.id,
    executedOn: DateTime.utc(2026, 1, 5),
    amountEur: amountEur,
    unitPrice: 100,
    priceCurrency: Currency.usd,
    eurUsdRate: 1.10,
    quantity: quantity,
    createdAt: DateTime.utc(2026, 1, 5),
  );
}

// Avec un taux de 1, la valeur d'une ligne vaut quantité × cours : les
// calculs qui suivent la valorisation se lisent sans conversion.
ValuedPortfolio valued(List<Position> positions, Map<String, double> prices) {
  final result = valuePortfolio(positions, latestPrices: prices, eurUsdRate: 1);
  return (result as Available<ValuedPortfolio>).value;
}

Matcher isConcentratedOn(Asset asset, double weight) {
  return isA<Concentrated>()
      .having((advice) => advice.asset.id, 'asset', asset.id)
      .having((advice) => advice.weight, 'weight', closeTo(weight, 1e-9));
}

Matcher isDiversifiedAcross(int assetTypeCount) {
  return isA<Diversified>().having(
    (advice) => advice.assetTypeCount,
    'assetTypeCount',
    assetTypeCount,
  );
}

void main() {
  group('quantité achetée', () {
    test('convertit le montant au taux d\'achat pour un actif en dollars', () {
      final quantity = computePurchasedQuantity(
        amountEur: 110,
        unitPrice: 60.5,
        priceCurrency: Currency.usd,
        eurUsdRate: 1.10,
      );

      expect(quantity, isAvailableCloseTo(2));
    });

    test('ignore le taux pour un actif coté en euros', () {
      final quantity = computePurchasedQuantity(
        amountEur: 100,
        unitPrice: 25,
        priceCurrency: Currency.eur,
        eurUsdRate: 1.10,
      );

      expect(quantity, isAvailableCloseTo(4));
    });

    test('renvoie indisponible pour un montant nul', () {
      final quantity = computePurchasedQuantity(
        amountEur: 0,
        unitPrice: 60.5,
        priceCurrency: Currency.usd,
        eurUsdRate: 1.10,
      );

      expect(quantity, isUnavailableBecause(UnavailableReason.invalidAmount));
    });

    test('renvoie indisponible pour un cours nul', () {
      final quantity = computePurchasedQuantity(
        amountEur: 110,
        unitPrice: 0,
        priceCurrency: Currency.usd,
        eurUsdRate: 1.10,
      );

      expect(quantity, isUnavailableBecause(UnavailableReason.invalidPrice));
    });

    test('renvoie indisponible pour un taux nul', () {
      final quantity = computePurchasedQuantity(
        amountEur: 110,
        unitPrice: 60.5,
        priceCurrency: Currency.usd,
        eurUsdRate: 0,
      );

      expect(quantity, isUnavailableBecause(UnavailableReason.invalidRate));
    });
  });

  group('positions', () {
    test('regroupe les achats d\'un même actif en une seule position', () {
      final positions = aggregatePositions([
        purchase(apple, quantity: 1, amountEur: 50),
        purchase(apple, quantity: 0.5, amountEur: 30),
      ], catalogue: catalogue);

      expect(positions, hasLength(1));
      expect(positions.single.quantity, closeTo(1.5, 1e-9));
      expect(positions.single.investedEur, closeTo(80, 1e-9));
    });

    test('crée une position par actif, dans l\'ordre du premier achat', () {
      final positions = aggregatePositions([
        purchase(apple, quantity: 1, amountEur: 50),
        purchase(spy, quantity: 1, amountEur: 400),
        purchase(apple, quantity: 1, amountEur: 60),
      ], catalogue: catalogue);

      expect(positions.map((position) => position.asset.id), ['AAPL', 'SPY']);
    });

    test('ne crée aucune position sans achat', () {
      expect(aggregatePositions([], catalogue: catalogue), isEmpty);
    });

    test('refuse un achat dont l\'actif est absent du catalogue', () {
      expect(
        () => aggregatePositions([
          purchase(apple, quantity: 1, amountEur: 50),
        ], catalogue: {}),
        throwsArgumentError,
      );
    });
  });

  group('valorisation', () {
    test('valorise une ligne en euros au dernier cours connu', () {
      final result = valuePortfolio(
        [const Position(asset: apple, quantity: 2, investedEur: 100)],
        latestPrices: {'AAPL': 66},
        eurUsdRate: 1.10,
      );

      final portfolio = (result as Available<ValuedPortfolio>).value;
      expect(portfolio.lines.single.valueEur, closeTo(120, 1e-9));
    });

    test('additionne la valeur des lignes', () {
      final portfolio = valued(
        [
          const Position(asset: apple, quantity: 2, investedEur: 90),
          const Position(asset: spy, quantity: 1, investedEur: 95),
        ],
        {'AAPL': 50, 'SPY': 100},
      );

      expect(portfolio.totalValueEur, closeTo(200, 1e-9));
    });

    test('renvoie indisponible pour un portefeuille vide', () {
      final result = valuePortfolio([], latestPrices: {}, eurUsdRate: 1.10);

      expect(result, isUnavailableBecause(UnavailableReason.emptyPortfolio));
    });

    test('renvoie indisponible quand le cours d\'une ligne manque', () {
      final result = valuePortfolio(
        [
          const Position(asset: apple, quantity: 2, investedEur: 100),
          const Position(asset: spy, quantity: 1, investedEur: 400),
        ],
        latestPrices: {'AAPL': 66},
        eurUsdRate: 1.10,
      );

      expect(result, isUnavailableBecause(UnavailableReason.missingPrice));
    });

    test('renvoie indisponible quand le cours d\'une ligne est nul', () {
      final result = valuePortfolio(
        [const Position(asset: apple, quantity: 2, investedEur: 100)],
        latestPrices: {'AAPL': 0},
        eurUsdRate: 1.10,
      );

      expect(result, isUnavailableBecause(UnavailableReason.invalidPrice));
    });

    test('renvoie indisponible quand le taux de change est nul', () {
      final result = valuePortfolio(
        [const Position(asset: apple, quantity: 2, investedEur: 100)],
        latestPrices: {'AAPL': 66},
        eurUsdRate: 0,
      );

      expect(result, isUnavailableBecause(UnavailableReason.invalidRate));
    });
  });

  group('gain et performance', () {
    test('calcule un gain', () {
      final portfolio = valued(
        [const Position(asset: apple, quantity: 2, investedEur: 200)],
        {'AAPL': 115},
      );

      expect(portfolio.gainEur, closeTo(30, 1e-9));
    });

    test('calcule une perte comme un gain négatif', () {
      final portfolio = valued(
        [const Position(asset: apple, quantity: 2, investedEur: 200)],
        {'AAPL': 75},
      );

      expect(portfolio.gainEur, closeTo(-50, 1e-9));
    });

    test('calcule la performance : 100 € devenus 120 € font +20 %', () {
      final performance = computePerformance(investedEur: 100, valueEur: 120);

      expect(performance, isAvailableCloseTo(0.20));
    });

    test('calcule une performance négative', () {
      final performance = computePerformance(investedEur: 200, valueEur: 150);

      expect(performance, isAvailableCloseTo(-0.25));
    });

    test(
      'renvoie une performance indisponible quand rien n\'a été investi',
      () {
        final performance = computePerformance(investedEur: 0, valueEur: 0);

        expect(
          performance,
          isUnavailableBecause(UnavailableReason.nothingInvested),
        );
      },
    );
  });

  group('répartition par type', () {
    test('répartit la valeur entre actions, ETF et cryptos', () {
      final portfolio = valued(
        [
          const Position(asset: apple, quantity: 1, investedEur: 30),
          const Position(asset: spy, quantity: 1, investedEur: 55),
          const Position(asset: bitcoin, quantity: 1, investedEur: 15),
        ],
        {'AAPL': 30, 'SPY': 55, 'bitcoin': 15},
      );

      final allocation = computeAllocationByType(portfolio);

      expect(allocation[AssetType.stock], closeTo(0.30, 1e-9));
      expect(allocation[AssetType.etf], closeTo(0.55, 1e-9));
      expect(allocation[AssetType.crypto], closeTo(0.15, 1e-9));
    });

    test('donne 100 % au seul type présent et 0 % aux autres', () {
      final portfolio = valued(
        [const Position(asset: spy, quantity: 2, investedEur: 800)],
        {'SPY': 420},
      );

      final allocation = computeAllocationByType(portfolio);

      expect(allocation[AssetType.etf], closeTo(1, 1e-9));
      expect(allocation[AssetType.stock], 0);
      expect(allocation[AssetType.crypto], 0);
    });

    test('donne des poids dont la somme vaut 1', () {
      final portfolio = valued(
        [
          const Position(asset: apple, quantity: 3, investedEur: 30),
          const Position(asset: spy, quantity: 0.7, investedEur: 40),
          const Position(asset: bitcoin, quantity: 0.01, investedEur: 600),
        ],
        {'AAPL': 12.3, 'SPY': 45.6, 'bitcoin': 78900},
      );

      final allocation = computeAllocationByType(portfolio);

      final sum = allocation.values.reduce((total, weight) => total + weight);
      expect(sum, closeTo(1, 1e-9));
    });
  });

  group('concentration', () {
    test('alerte quand une ligne dépasse 50 % du portefeuille', () {
      final portfolio = valued(
        [
          const Position(asset: apple, quantity: 1, investedEur: 60),
          const Position(asset: spy, quantity: 1, investedEur: 30),
        ],
        {'AAPL': 70, 'SPY': 30},
      );

      expect(computeConcentration(portfolio), isConcentratedOn(apple, 0.70));
    });

    test('n\'alerte pas pour une ligne à exactement 50 %', () {
      final portfolio = valued(
        [
          const Position(asset: apple, quantity: 1, investedEur: 50),
          const Position(asset: spy, quantity: 1, investedEur: 50),
        ],
        {'AAPL': 50, 'SPY': 50},
      );

      expect(computeConcentration(portfolio), isDiversifiedAcross(2));
    });

    test('alerte pour un portefeuille d\'une seule ligne', () {
      final portfolio = valued(
        [const Position(asset: bitcoin, quantity: 0.01, investedEur: 500)],
        {'bitcoin': 90000},
      );

      expect(computeConcentration(portfolio), isConcentratedOn(bitcoin, 1));
    });

    test('compte les types d\'actifs quand aucune ligne ne domine', () {
      final portfolio = valued(
        [
          const Position(asset: apple, quantity: 1, investedEur: 40),
          const Position(asset: spy, quantity: 1, investedEur: 30),
          const Position(asset: bitcoin, quantity: 1, investedEur: 30),
        ],
        {'AAPL': 40, 'SPY': 30, 'bitcoin': 30},
      );

      expect(computeConcentration(portfolio), isDiversifiedAcross(3));
    });
  });
}
