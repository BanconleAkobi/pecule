import 'package:pecule/domain/models/asset.dart';

sealed class ConcentrationAdvice {
  const ConcentrationAdvice();
}

/// Une ligne pèse plus de la moitié du portefeuille.
final class Concentrated extends ConcentrationAdvice {
  const Concentrated({required this.asset, required this.weight});

  final Asset asset;
  final double weight;
}

final class Diversified extends ConcentrationAdvice {
  const Diversified({required this.assetTypeCount});

  final int assetTypeCount;
}
