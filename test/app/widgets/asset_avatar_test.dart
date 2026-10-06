import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/widgets/asset_avatar.dart';
import 'package:pecule/data/catalogue.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('affiche le symbole d\'une crypto', (tester) async {
    await pumpInApp(tester, AssetAvatar(asset: catalogueById['bitcoin']!));

    expect(find.text('BTC'), findsOneWidget);
  });

  testWidgets('garde trois lettres au plus', (tester) async {
    await pumpInApp(tester, AssetAvatar(asset: catalogueById['GOOGL']!));

    expect(find.text('GOO'), findsOneWidget);
  });
}
