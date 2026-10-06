import 'package:pecule/domain/models/currency.dart';

class PaperTransaction {
  const PaperTransaction({
    required this.assetId,
    required this.executedOn,
    required this.amountEur,
    required this.unitPrice,
    required this.priceCurrency,
    required this.eurUsdRate,
    required this.quantity,
    required this.createdAt,
  });

  final String assetId;
  final DateTime executedOn;
  final double amountEur;

  // Cours et taux sont figés au moment de l'achat : la valeur d'achat ne
  // change jamais, même si le cache est vidé.
  final double unitPrice;
  final Currency priceCurrency;
  final double eurUsdRate;

  final double quantity;
  final DateTime createdAt;
}
