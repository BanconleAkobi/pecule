import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/navigation/app_tab.dart';
import 'package:pecule/app/pecule_app.dart';
import 'package:pecule/features/explorer/explorer_screen.dart';
import 'package:pecule/features/patrimoine/patrimoine_screen.dart';

void main() {
  testWidgets('affiche les quatre onglets', (tester) async {
    await tester.pumpWidget(const PeculeApp());

    for (final tab in AppTab.values) {
      expect(find.text(tab.label), findsOneWidget);
    }
  });

  testWidgets("s'ouvre sur l'onglet Patrimoine", (tester) async {
    await tester.pumpWidget(const PeculeApp());

    expect(find.byType(PatrimoineScreen), findsOneWidget);
    expect(find.byType(ExplorerScreen), findsNothing);
  });

  testWidgets("affiche l'Explorer quand on touche son onglet", (tester) async {
    await tester.pumpWidget(const PeculeApp());

    await tester.tap(find.text(AppTab.explorer.label));
    await tester.pumpAndSettle();

    expect(find.byType(ExplorerScreen), findsOneWidget);
    expect(find.byType(PatrimoineScreen), findsNothing);
  });
}
