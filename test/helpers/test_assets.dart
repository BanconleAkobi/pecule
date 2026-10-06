import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/currency.dart';

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
