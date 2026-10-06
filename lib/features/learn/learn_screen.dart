import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_spacing.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: PeculeSpacing.tabScreen,
        children: [
          Text(
            'Ton parcours',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
