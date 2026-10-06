import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pecule/app/font_licenses.dart';
import 'package:pecule/app/pecule_app.dart';

Future<void> main() async {
  await initializeDateFormatting('fr_FR');
  registerFontLicenses();
  runApp(const PeculeApp());
}
