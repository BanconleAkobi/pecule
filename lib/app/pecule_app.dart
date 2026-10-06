import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pecule/app/navigation/app_shell.dart';
import 'package:pecule/app/theme/pecule_theme.dart';

class PeculeApp extends StatelessWidget {
  const PeculeApp({super.key});

  static const _french = Locale('fr', 'FR');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pécule',
      debugShowCheckedModeBanner: false,
      theme: buildPeculeTheme(),
      locale: _french,
      supportedLocales: const [_french],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const AppShell(),
    );
  }
}
