import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/core/formatters.dart';
import 'package:pecule/domain/computed.dart';

/// Une variation affichée « ▲ +12,6 % » en vert ou « ▼ −8,4 % » en rouge.
/// Le signe et la flèche disent le sens sans compter sur la couleur.
class SignedChange extends StatelessWidget {
  const SignedChange({super.key, required this.change, this.style});

  static const unavailableText = '—';

  final Computed<double> change;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.peculeColors;
    final baseStyle = (style ?? DefaultTextStyle.of(context).style).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    switch (change) {
      case Available(:final value):
        final text = formatPercentWithArrow(value);
        final isLoss = text.startsWith('▼');
        return Text(
          text,
          style: baseStyle.copyWith(color: isLoss ? colors.loss : colors.gain),
        );
      case Unavailable():
        return Text(
          unavailableText,
          style: baseStyle.copyWith(color: colors.textMuted),
        );
    }
  }
}
