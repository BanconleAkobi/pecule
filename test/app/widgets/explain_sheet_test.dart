import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/widgets/explain_sheet.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('traduit un chiffre en phrase, puis se ferme sur « Compris »', (
    tester,
  ) async {
    await pumpInApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showExplainSheet(
            context,
            title: '+16,1 %, en clair',
            text: 'Pour chaque 100 € placés, tu as gagné 16,10 €.',
          ),
          child: const Text('+16,1 %'),
        ),
      ),
    );

    await tester.tap(find.text('+16,1 %'));
    await tester.pumpAndSettle();
    expect(find.text('EN CLAIR'), findsOneWidget);
    expect(find.text('+16,1 %, en clair'), findsOneWidget);

    await tester.tap(find.text('Compris'));
    await tester.pumpAndSettle();
    expect(find.text('EN CLAIR'), findsNothing);
  });
}
