import 'package:flutter/material.dart';

/// Ligne grise qui pulse à l'emplacement exact d'une ligne d'actif, le temps
/// du premier chargement.
class SkeletonRow extends StatefulWidget {
  const SkeletonRow({super.key});

  @override
  State<SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<SkeletonRow>
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
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    return FadeTransition(
      opacity: _pulse,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            _Block(width: 42, height: 42, color: color, isRound: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.55,
                    child: _Block(height: 12, color: color),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.3,
                    child: _Block(height: 9, color: color),
                  ),
                ],
              ),
            ),
            _Block(width: 64, height: 12, color: color),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    this.width,
    required this.height,
    required this.color,
    this.isRound = false,
  });

  final double? width;
  final double height;
  final Color color;
  final bool isRound;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: isRound ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isRound ? null : BorderRadius.circular(height / 2),
      ),
    );
  }
}
