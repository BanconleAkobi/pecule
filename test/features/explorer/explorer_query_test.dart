import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/data/catalogue.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/features/explorer/explorer_query.dart';

List<String> idsOf(List<Asset> assets) =>
    assets.map((asset) => asset.id).toList();

void main() {
  List<Asset> filter(ExplorerQuery query, {Set<String> favorites = const {}}) =>
      filterCatalogue(catalogue, query, favoriteAssetIds: favorites);

  group('recherche', () {
    test('trouve un actif par son nom, sans tenir compte des majuscules', () {
      expect(idsOf(filter(const ExplorerQuery(text: 'COCA'))), ['KO']);
    });

    test('trouve un actif par son symbole', () {
      expect(idsOf(filter(const ExplorerQuery(text: 'btc'))), ['bitcoin']);
    });

    test('ignore les espaces autour du texte', () {
      expect(idsOf(filter(const ExplorerQuery(text: '  tesla '))), ['TSLA']);
    });

    test('renvoie tout le catalogue sans texte', () {
      expect(filter(const ExplorerQuery()), hasLength(30));
    });
  });

  group('filtres', () {
    test('ne garde que les cryptos', () {
      final cryptos = filter(
        const ExplorerQuery(filter: ExplorerFilter.cryptos),
      );

      expect(cryptos, hasLength(10));
    });

    test('ne garde que les favoris', () {
      final favorites = filter(
        const ExplorerQuery(filter: ExplorerFilter.favorites),
        favorites: {'AAPL', 'bitcoin'},
      );

      expect(idsOf(favorites), ['AAPL', 'bitcoin']);
    });

    test('combine la recherche et le filtre', () {
      final result = filter(
        const ExplorerQuery(text: 'vanguard', filter: ExplorerFilter.etfs),
      );

      expect(result, hasLength(5));
    });
  });

  test('garder le filtre en changeant la recherche', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(explorerQueryProvider.notifier);

    notifier.filterBy(ExplorerFilter.etfs);
    notifier.search('spy');

    final query = container.read(explorerQueryProvider);
    expect(query.filter, ExplorerFilter.etfs);
    expect(query.text, 'spy');
  });
}
