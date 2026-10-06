import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/theme/pecule_palette.dart';
import 'package:pecule/app/widgets/signed_change.dart';
import 'package:pecule/domain/computed.dart';

import '../../helpers/pump_app.dart';

Color colorOf(WidgetTester tester, Finder finder) =>
    tester.widget<Text>(finder).style!.color!;

void main() {
  testWidgets('affiche une hausse en vert, avec signe et flèche', (
    tester,
  ) async {
    await pumpInApp(tester, const SignedChange(change: Available(0.126)));

    final text = find.text('▲ +12,6 %');
    expect(text, findsOneWidget);
    expect(colorOf(tester, text), PeculePalette.gain);
  });

  testWidgets('affiche une baisse en rouge, avec le vrai signe moins', (
    tester,
  ) async {
    await pumpInApp(tester, const SignedChange(change: Available(-0.084)));

    final text = find.text('▼ −8,4 %');
    expect(text, findsOneWidget);
    expect(colorOf(tester, text), PeculePalette.loss);
  });

  testWidgets('affiche un tiret discret quand la variation est indisponible', (
    tester,
  ) async {
    await pumpInApp(
      tester,
      const SignedChange(
        change: Unavailable(UnavailableReason.notEnoughPrices),
      ),
    );

    expect(find.text(SignedChange.unavailableText), findsOneWidget);
  });
}
