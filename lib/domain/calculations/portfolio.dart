import 'package:pecule/domain/calculations/currency.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/concentration_advice.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/paper_transaction.dart';
import 'package:pecule/domain/models/position.dart';
import 'package:pecule/domain/models/valued_portfolio.dart';

const concentrationThreshold = 0.5;

Computed<double> computePurchasedQuantity({
  required double amountEur,
  required double unitPrice,
  required Currency priceCurrency,
  required double eurUsdRate,
}) {
  if (amountEur <= 0) return const Unavailable(UnavailableReason.invalidAmount);
  if (unitPrice <= 0) return const Unavailable(UnavailableReason.invalidPrice);
  if (priceCurrency == Currency.usd && eurUsdRate <= 0) {
    return const Unavailable(UnavailableReason.invalidRate);
  }
  final unitPriceEur = convertToEur(
    unitPrice,
    from: priceCurrency,
    eurUsdRate: eurUsdRate,
  );
  return Available(amountEur / unitPriceEur);
}

List<Position> aggregatePositions(
  List<PaperTransaction> transactions, {
  required Map<String, Asset> catalogue,
}) {
  final positionsByAssetId = <String, Position>{};
  for (final transaction in transactions) {
    final asset =
        catalogue[transaction.assetId] ??
        (throw ArgumentError.value(
          transaction.assetId,
          'assetId',
          'absent du catalogue',
        ));
    final current = positionsByAssetId[asset.id];
    positionsByAssetId[asset.id] = Position(
      asset: asset,
      quantity: (current?.quantity ?? 0) + transaction.quantity,
      investedEur: (current?.investedEur ?? 0) + transaction.amountEur,
    );
  }
  return positionsByAssetId.values.toList();
}

/// [latestPrices] : dernier cours connu de chaque actif, dans sa devise.
Computed<ValuedPortfolio> valuePortfolio(
  List<Position> positions, {
  required Map<String, double> latestPrices,
  required double eurUsdRate,
}) {
  if (positions.isEmpty) {
    return const Unavailable(UnavailableReason.emptyPortfolio);
  }
  if (eurUsdRate <= 0) return const Unavailable(UnavailableReason.invalidRate);

  final lines = <ValuedPosition>[];
  for (final position in positions) {
    final price = latestPrices[position.asset.id];
    if (price == null) return const Unavailable(UnavailableReason.missingPrice);
    if (price <= 0) return const Unavailable(UnavailableReason.invalidPrice);

    final priceEur = convertToEur(
      price,
      from: position.asset.currency,
      eurUsdRate: eurUsdRate,
    );
    lines.add(
      ValuedPosition(
        position: position,
        valueEur: position.quantity * priceEur,
      ),
    );
  }
  return Available(ValuedPortfolio(lines));
}

Computed<double> computePerformance({
  required double investedEur,
  required double valueEur,
}) {
  if (investedEur <= 0) {
    return const Unavailable(UnavailableReason.nothingInvested);
  }
  return Available(valueEur / investedEur - 1);
}

/// Poids de chaque type d'actif dans la valeur totale. Les types absents
/// valent 0, pour que l'anneau et sa légende les affichent tous.
Map<AssetType, double> computeAllocationByType(ValuedPortfolio portfolio) {
  final total = portfolio.totalValueEur;
  return {
    for (final type in AssetType.values)
      type:
          portfolio.lines
              .where((line) => line.position.asset.type == type)
              .fold<double>(0, (sum, line) => sum + line.valueEur) /
          total,
  };
}

ConcentrationAdvice computeConcentration(ValuedPortfolio portfolio) {
  final heaviest = portfolio.lines.reduce(
    (heaviest, line) => line.valueEur > heaviest.valueEur ? line : heaviest,
  );
  final weight = heaviest.valueEur / portfolio.totalValueEur;
  if (weight > concentrationThreshold) {
    return Concentrated(asset: heaviest.position.asset, weight: weight);
  }

  final assetTypes = portfolio.lines.map((line) => line.position.asset.type);
  return Diversified(assetTypeCount: assetTypes.toSet().length);
}
