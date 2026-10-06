import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';
import 'package:pecule/domain/models/currency.dart';

/// Les trente actifs de Pécule (cahier des charges, section 5.2), tous cotés
/// en dollars pour rendre l'effet de change visible partout. L'identifiant est
/// celui du fournisseur : symbole Twelve Data ou identifiant CoinGecko.
///
/// On n'en retire jamais un actif : des achats ou des favoris peuvent y
/// renvoyer (règle du MCD).
const catalogue = [
  Asset(
    id: 'AAPL',
    name: 'Apple',
    symbol: 'AAPL',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'MSFT',
    name: 'Microsoft',
    symbol: 'MSFT',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'NVDA',
    name: 'Nvidia',
    symbol: 'NVDA',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'AMZN',
    name: 'Amazon',
    symbol: 'AMZN',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'GOOGL',
    name: 'Alphabet',
    symbol: 'GOOGL',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'META',
    name: 'Meta',
    symbol: 'META',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'TSLA',
    name: 'Tesla',
    symbol: 'TSLA',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'KO',
    name: 'Coca-Cola',
    symbol: 'KO',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'JNJ',
    name: 'Johnson & Johnson',
    symbol: 'JNJ',
    type: AssetType.stock,
    currency: Currency.usd,
  ),
  Asset(
    id: 'V',
    name: 'Visa',
    symbol: 'V',
    type: AssetType.stock,
    currency: Currency.usd,
  ),

  Asset(
    id: 'SPY',
    name: 'SPDR S&P 500',
    symbol: 'SPY',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'QQQ',
    name: 'Invesco Nasdaq 100',
    symbol: 'QQQ',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'VT',
    name: 'Vanguard Total World',
    symbol: 'VT',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'VEA',
    name: 'Vanguard Developed Markets',
    symbol: 'VEA',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'VWO',
    name: 'Vanguard Emerging Markets',
    symbol: 'VWO',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'BND',
    name: 'Vanguard Total Bond',
    symbol: 'BND',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'GLD',
    name: 'SPDR Gold',
    symbol: 'GLD',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'VNQ',
    name: 'Vanguard Real Estate',
    symbol: 'VNQ',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'SCHD',
    name: 'Schwab US Dividend',
    symbol: 'SCHD',
    type: AssetType.etf,
    currency: Currency.usd,
  ),
  Asset(
    id: 'IWM',
    name: 'iShares Russell 2000',
    symbol: 'IWM',
    type: AssetType.etf,
    currency: Currency.usd,
  ),

  Asset(
    id: 'bitcoin',
    name: 'Bitcoin',
    symbol: 'BTC',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'ethereum',
    name: 'Ethereum',
    symbol: 'ETH',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'solana',
    name: 'Solana',
    symbol: 'SOL',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'binancecoin',
    name: 'BNB',
    symbol: 'BNB',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'ripple',
    name: 'XRP',
    symbol: 'XRP',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'cardano',
    name: 'Cardano',
    symbol: 'ADA',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'dogecoin',
    name: 'Dogecoin',
    symbol: 'DOGE',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'avalanche-2',
    name: 'Avalanche',
    symbol: 'AVAX',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'chainlink',
    name: 'Chainlink',
    symbol: 'LINK',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
  Asset(
    id: 'polkadot',
    name: 'Polkadot',
    symbol: 'DOT',
    type: AssetType.crypto,
    currency: Currency.usd,
  ),
];

final catalogueById = {for (final asset in catalogue) asset.id: asset};
