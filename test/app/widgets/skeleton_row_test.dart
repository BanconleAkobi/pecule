import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/widgets/skeleton_row.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('pulse puis libère son animation quand il disparaît', (
    tester,
  ) async {
    await pumpInApp(tester, const SkeletonRow());
    await tester.pump(const Duration(milliseconds: 350));

    await pumpInApp(tester, const SizedBox());

    expect(find.byType(SkeletonRow), findsNothing);
  });
}
