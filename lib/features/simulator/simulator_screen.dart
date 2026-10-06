import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_spacing.dart';

class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: PeculeSpacing.tabScreen,
        children: [
          Text(
            "Et si j'avais investi… ?",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
