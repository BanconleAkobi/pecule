import 'package:pecule/domain/models/asset.dart';

/// Tous les achats d'un même actif, cumulés.
class Position {
  const Position({
    required this.asset,
    required this.quantity,
    required this.investedEur,
  });

  final Asset asset;
  final double quantity;
  final double investedEur;
}
