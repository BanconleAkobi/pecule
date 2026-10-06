import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_type.dart';

enum ExplorerFilter {
  all,
  stocks,
  etfs,
  cryptos,
  favorites;

  bool accepts(Asset asset, Set<String> favoriteAssetIds) => switch (this) {
    ExplorerFilter.all => true,
    ExplorerFilter.stocks => asset.type == AssetType.stock,
    ExplorerFilter.etfs => asset.type == AssetType.etf,
    ExplorerFilter.cryptos => asset.type == AssetType.crypto,
    ExplorerFilter.favorites => favoriteAssetIds.contains(asset.id),
  };
}

class ExplorerQuery {
  const ExplorerQuery({this.text = '', this.filter = ExplorerFilter.all});

  final String text;
  final ExplorerFilter filter;

  bool get hasText => text.trim().isNotEmpty;
}

final explorerQueryProvider =
    NotifierProvider<ExplorerQueryNotifier, ExplorerQuery>(
      ExplorerQueryNotifier.new,
    );

class ExplorerQueryNotifier extends Notifier<ExplorerQuery> {
  @override
  ExplorerQuery build() => const ExplorerQuery();

  void search(String text) =>
      state = ExplorerQuery(text: text, filter: state.filter);

  void filterBy(ExplorerFilter filter) =>
      state = ExplorerQuery(text: state.text, filter: filter);
}

/// Recherche dans le nom ou le symbole, sans tenir compte des majuscules,
/// puis filtre par type ou par favori. Tout se passe en local : aucun appel
/// réseau à la frappe (cahier des charges, section 4.3).
List<Asset> filterCatalogue(
  List<Asset> assets,
  ExplorerQuery query, {
  required Set<String> favoriteAssetIds,
}) {
  final text = query.text.trim().toLowerCase();
  return assets.where((asset) {
    final matchesText =
        text.isEmpty ||
        asset.name.toLowerCase().contains(text) ||
        asset.symbol.toLowerCase().contains(text);
    return matchesText && query.filter.accepts(asset, favoriteAssetIds);
  }).toList();
}
