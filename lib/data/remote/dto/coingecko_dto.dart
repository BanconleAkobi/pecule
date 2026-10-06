class CoinGeckoMarketChartDto {
  const CoinGeckoMarketChartDto({
    required this.prices,
    required this.marketCaps,
    required this.totalVolumes,
  });

  factory CoinGeckoMarketChartDto.fromJson(Map<String, dynamic> json) {
    return CoinGeckoMarketChartDto(
      prices: _points(json['prices']),
      marketCaps: _points(json['market_caps']),
      totalVolumes: _points(json['total_volumes']),
    );
  }

  final List<CoinGeckoPointDto> prices;
  final List<CoinGeckoPointDto> marketCaps;
  final List<CoinGeckoPointDto> totalVolumes;

  static List<CoinGeckoPointDto> _points(Object? json) => [
    for (final pair in json! as List<dynamic>)
      CoinGeckoPointDto.fromJson(pair as List<dynamic>),
  ];
}

/// Un point `[horodatage en millisecondes, valeur]`.
class CoinGeckoPointDto {
  const CoinGeckoPointDto({required this.day, required this.value});

  // Avec interval=daily, chaque point tombe à minuit UTC. On ne garde que le
  // jour, au cas où le dernier point porterait l'heure de la requête.
  factory CoinGeckoPointDto.fromJson(List<dynamic> pair) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      pair[0] as int,
      isUtc: true,
    );
    return CoinGeckoPointDto(
      day: DateTime.utc(timestamp.year, timestamp.month, timestamp.day),
      value: (pair[1] as num).toDouble(),
    );
  }

  final DateTime day;
  final double value;
}

class CoinGeckoMarketDto {
  const CoinGeckoMarketDto({
    required this.id,
    required this.currentPrice,
    required this.priceChangePercentage1y,
    required this.lastUpdated,
  });

  factory CoinGeckoMarketDto.fromJson(Map<String, dynamic> json) {
    return CoinGeckoMarketDto(
      id: json['id'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChangePercentage1y:
          (json['price_change_percentage_1y_in_currency'] as num?)?.toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  final String id;
  final double currentPrice;

  /// En pourcentage (−30,57 pour une baisse de 30,57 %). Vide pour une crypto
  /// qui n'a pas encore un an d'historique.
  final double? priceChangePercentage1y;

  final DateTime lastUpdated;
}
