import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/currency.dart';

class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.currency,
  });

  final String id;
  final String name;
  final String symbol;
  final AssetType type;
  final Currency currency;
}
