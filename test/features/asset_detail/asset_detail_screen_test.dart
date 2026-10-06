import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/features/asset_detail/asset_detail_screen.dart';
import 'package:pecule/features/asset_detail/widgets/price_chart.dart';

import '../../helpers/apple_history.dart';
import '../../helpers/fake_repositories.dart';

const unit = ' ';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  Future<void> pumpApple(WidgetTester tester) async {
    await pumpScreen(
      tester,
      const AssetDetailScreen(assetId: 'AAPL'),
      overrides: fakeAppOverrides(
        prices: FakePriceHistoryRepository({'AAPL': appleYear}),
        rates: FakeFxRateRepository(stableEuro),
      ),
    );
    // L'historique et les taux arrivent par deux flux combinés : on attend
    // que tout soit affiché.
    await tester.pumpAndSettle();
  }

  testWidgets('affiche le nom, le cours en euros et la variation sur un an', (
    tester,
  ) async {
    await pumpApple(tester);

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('AAPL · Action'), findsOneWidget);
    expect(find.text('120,00$unit€'), findsOneWidget);
    expect(find.text('▲ +20,0$unit%'), findsWidgets);
    expect(find.text('sur 1 an'), findsOneWidget);
  });

  testWidgets('change la période de la courbe', (tester) async {
    await pumpApple(tester);

    await tester.tap(find.text('1M'));
    await tester.pump();

    expect(find.text('sur 1 mois'), findsOneWidget);
  });

  testWidgets('affiche la date et la variation du point touché', (
    tester,
  ) async {
    await pumpApple(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PriceChart)),
    );
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump();

    expect(find.textContaining('au '), findsOneWidget);
    await gesture.up();
  });

  testWidgets('traduit la variation en phrase au toucher', (tester) async {
    await pumpApple(tester);

    await tester.tap(find.text('▲ +20,0$unit%').first);
    await tester.pumpAndSettle();

    expect(find.text('EN CLAIR'), findsOneWidget);
    expect(find.textContaining('dans Apple il y a un an'), findsOneWidget);
  });

  testWidgets('détaille le score de stabilité à la demande', (tester) async {
    await pumpApple(tester);
    // Plus bas que le bouton du score, pour qu'il ne reste pas sous le bouton
    // fixe « Ajouter à mon portefeuille ».
    await tester.scrollUntilVisible(find.text('Ça veut dire quoi ?'), 300);

    await tester.tap(find.text('Comprendre ce score ↓'));
    await tester.pump();

    expect(find.text('Stable'), findsOneWidget);
    expect(find.text('Masquer le détail ↑'), findsOneWidget);
    expect(find.textContaining('Volatilité'), findsWidgets);
  });

  testWidgets(
    'hors connexion, un actif jamais téléchargé a un état vide clair',
    (tester) async {
      await pumpScreen(
        tester,
        const AssetDetailScreen(assetId: 'TSLA'),
        overrides: fakeAppOverrides(
          prices: FakePriceHistoryRepository(
            const {},
            const NetworkException('hors ligne'),
          ),
          rates: FakeFxRateRepository(stableEuro),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Pas encore de cours pour cet actif. Connecte-toi pour les télécharger.',
        ),
        findsOneWidget,
      );
    },
  );
}
