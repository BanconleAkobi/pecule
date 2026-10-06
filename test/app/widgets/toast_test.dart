import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/widgets/toast.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('affiche une confirmation brève', (tester) async {
    await pumpInApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showToast(context, 'Ajouté à tes favoris'),
          child: const Text('♡'),
        ),
      ),
    );

    await tester.tap(find.text('♡'));
    await tester.pump();

    expect(find.text('Ajouté à tes favoris'), findsOneWidget);
  });
}
