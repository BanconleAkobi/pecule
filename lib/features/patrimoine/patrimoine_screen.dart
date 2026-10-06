import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_spacing.dart';

class PatrimoineScreen extends StatelessWidget {
  const PatrimoineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wordmarkStyle = Theme.of(context).textTheme.headlineSmall
        ?.copyWith(fontStyle: FontStyle.italic);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: PeculeSpacing.tabScreen,
        children: [Text('pécule', style: wordmarkStyle)],
      ),
    );
  }
}
