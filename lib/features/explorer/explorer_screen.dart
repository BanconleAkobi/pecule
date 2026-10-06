import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_spacing.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: PeculeSpacing.tabScreen,
        children: [
          Text('Explorer', style: Theme.of(context).textTheme.headlineLarge),
        ],
      ),
    );
  }
}
