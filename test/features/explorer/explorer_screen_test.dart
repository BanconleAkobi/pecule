import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/domain/models/currency.dart';
import 'package:pecule/domain/models/fx_rate.dart';
import 'package:pecule/domain/models/price_bar.dart';
import 'package:pecule/features/asset_detail/asset_detail_screen.dart';
import 'package:pecule/features/explorer/explorer_query.dart';
import 'package:pecule/features/explorer/explorer_screen.dart';
import 'package:pecule/features/explorer/widgets/filter_chips.dart';

import '../../helpers/fake_repositories.dart';

PriceBar closeOn(DateTime day, double close) =>
    PriceBar(day: day, close: close, volume: 0);

void main() {
  late FakeFavoritesRepository favorites;

  setUp(() => favorites = FakeFavoritesRepository());

  // Apple passe de 110 $ à 132 $ en un an, avec un euro à 1,10 $ : 120 € et
  // +20 %.
  Future<void> pumpExplorer(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const ExplorerScreen(),
      overrides: fakeAppOverrides(
        prices: FakePriceHistoryRepository({
          'AAPL': [
            closeOn(DateTime.utc(2025, 10, 7), 110),
            closeOn(DateTime.utc(2026, 10, 7), 132),
          ],
        }),
        rates: FakeFxRateRepository([
          FxRate(
            day: DateTime.utc(2025, 1, 2),
            base: Currency.eur,
            quote: Currency.usd,
            rate: 1.10,
          ),
        ]),
        favorites: favorites,
      ),
    );
    await tester.pump();
  }

  testWidgets('affiche le cours en euros et la variation sur un an', (
    tester,
  ) async {
    await pumpExplorer(tester);

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('120,00 €'), findsOneWidget);
    expect(find.text('▲ +20,0 %'), findsOneWidget);
  });

  testWidgets('annonce le nombre d\'actifs et la période de la variation', (
    tester,
  ) async {
    await pumpExplorer(tester);

    expect(find.text('30 ACTIFS · VARIATION SUR 1 AN'), findsOneWidget);
  });

  testWidgets('filtre à la frappe, sur le nom ou le symbole', (tester) async {
    await pumpExplorer(tester);

    await tester.enterText(find.byType(TextField), 'tes');
    await tester.pump();

    expect(find.text('Tesla'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('propose d\'effacer une recherche sans résultat', (tester) async {
    await pumpExplorer(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('Aucun résultat'), findsOneWidget);

    await tester.tap(find.text('Effacer la recherche'));
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('invite à ajouter un premier favori', (tester) async {
    await pumpExplorer(tester);

    await tester.tap(find.text(FilterChips.labelOf(ExplorerFilter.favorites)));
    await tester.pump();

    expect(find.text('Pas encore de favori'), findsOneWidget);
  });

  testWidgets('ouvre la fiche d\'un actif au toucher de sa ligne', (
    tester,
  ) async {
    await pumpExplorer(tester);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(find.byType(AssetDetailScreen), findsOneWidget);
  });

  testWidgets('ajoute un favori au toucher du cœur et le confirme', (
    tester,
  ) async {
    await pumpExplorer(tester);

    await tester.tap(find.text('♡').first);
    await tester.pump();

    expect(find.text('Ajouté à tes favoris'), findsOneWidget);
    expect(favorites.assetIds, ['AAPL']);
  });
}
