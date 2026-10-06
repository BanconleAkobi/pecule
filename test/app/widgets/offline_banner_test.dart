import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pecule/app/widgets/offline_banner.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('indique la date des données affichées', (tester) async {
    await pumpInApp(
      tester,
      OfflineBanner(dataUpdatedAt: DateTime(2026, 10, 4, 18, 2)),
    );

    expect(
      find.text('Hors connexion · données du 4 oct. à 18:02'),
      findsOneWidget,
    );
  });

  testWidgets('se contente de « Hors connexion » sans date', (tester) async {
    await pumpInApp(tester, const OfflineBanner(dataUpdatedAt: null));

    expect(find.text('Hors connexion'), findsOneWidget);
  });
}
