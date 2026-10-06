import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';

// Sans le sélecteur U+FE0E, iOS affiche ♥ en emoji rouge au lieu d'un cœur
// dans la couleur du texte.
const filledHeart = '♥︎';
const emptyHeart = '♡';

/// Le cœur des favoris. Il bat au toucher : il grossit puis revient, ce qui
/// confirme l'action sans message.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  static const _beatDuration = Duration(milliseconds: 450);
  static const _beatScale = 1.45;

  late final AnimationController _beat;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _beat = AnimationController(vsync: this, duration: _beatDuration);
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: _beatScale), weight: 40),
      TweenSequenceItem(tween: Tween(begin: _beatScale, end: 1.0), weight: 60),
    ]).animate(_beat);
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  void _handleTap() {
    _beat.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isFavorite
        ? Theme.of(context).colorScheme.primary
        : context.peculeColors.textMuted;

    return Semantics(
      button: true,
      label: widget.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: SizedBox(
          width: 36,
          height: 44,
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Text(
                widget.isFavorite ? filledHeart : emptyHeart,
                style: TextStyle(fontSize: 19, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
