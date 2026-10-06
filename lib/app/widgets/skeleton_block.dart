import 'package:flutter/material.dart';

/// Bloc gris qui pulse à l'emplacement d'une valeur pas encore arrivée.
class SkeletonBlock extends StatefulWidget {
  const SkeletonBlock({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  // Un aller-retour complet dure 1,4 s, comme dans la maquette.
  static const _pulseDuration = Duration(milliseconds: 700);

  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: _pulseDuration,
      lowerBound: 0.45,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
      ),
    );
  }
}
