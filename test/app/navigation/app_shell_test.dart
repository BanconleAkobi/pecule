import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/navigation/app_tab.dart';
import 'package:pecule/app/pecule_app.dart';
import 'package:pecule/features/explorer/explorer_screen.dart';
import 'package:pecule/features/patrimoine/patrimoine_screen.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {bool isOffline = false}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeAppOverrides(isOffline: isOffline),
        child: const PeculeApp(),
      ),
    );
    await tester.pump();
  }

  testWidgets('affiche les quatre onglets', (tester) async {
    await pumpApp(tester);

    for (final tab in AppTab.values) {
      expect(find.text(tab.label), findsOneWidget);
    }
  });

  testWidgets("s'ouvre sur l'onglet Patrimoine", (tester) async {
    await pumpApp(tester);

    expect(find.byType(PatrimoineScreen), findsOneWidget);
    expect(find.byType(ExplorerScreen), findsNothing);
  });

  testWidgets("affiche l'Explorer quand on touche son onglet", (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(AppTab.explorer.label));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ExplorerScreen), findsOneWidget);
    expect(find.byType(PatrimoineScreen), findsNothing);
  });

  testWidgets('affiche le bandeau hors connexion au-dessus des onglets', (
    tester,
  ) async {
    await pumpApp(tester, isOffline: true);

    expect(find.textContaining('Hors connexion'), findsOneWidget);
  });
}
