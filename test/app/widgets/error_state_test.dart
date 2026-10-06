import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/widgets/error_state.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('affiche le message et relance au toucher de « Réessayer »', (
    tester,
  ) async {
    var retries = 0;
    await pumpInApp(
      tester,
      ErrorState(
        message: 'Impossible de charger les cours.',
        onRetry: () => retries++,
      ),
    );

    await tester.tap(find.text('Réessayer'));

    expect(find.text('Impossible de charger les cours.'), findsOneWidget);
    expect(retries, 1);
  });
}
