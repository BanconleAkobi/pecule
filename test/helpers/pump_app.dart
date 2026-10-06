import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/theme/pecule_theme.dart';

/// Affiche [child] dans une application au thème de Pécule.
Future<void> pumpInApp(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildPeculeTheme(),
      home: Scaffold(body: child),
    ),
  );
}
