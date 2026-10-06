import 'package:pecule/domain/computed.dart';

/// Ce que l'Explorer affiche pour un actif : son dernier cours en euros et sa
/// variation sur un an.
class AssetQuote {
  const AssetQuote({required this.latestPriceEur, required this.yearChange});

  final Computed<double> latestPriceEur;
  final Computed<double> yearChange;
}
