import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:pecule/app/font_licenses.dart';
import 'package:pecule/app/pecule_app.dart';
import 'package:pecule/data/local/pecule_database.dart';

Future<void> main() async {
  // Nécessaire avant d'appeler le système (dossier de la base) hors d'un widget.
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  registerFontLicenses();
  final database = await openDeviceDatabase();

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const PeculeApp(),
    ),
  );
}
