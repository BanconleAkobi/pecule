import 'package:pecule/domain/models/asset_type.dart';

String assetTypeLabel(AssetType type) => switch (type) {
  AssetType.stock => 'Action',
  AssetType.etf => 'ETF',
  AssetType.crypto => 'Crypto',
};
