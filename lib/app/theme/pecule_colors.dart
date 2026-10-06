import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_palette.dart';

/// Couleurs de la maquette qui n'ont pas de rôle dans le [ColorScheme] de Material.
class PeculeColors extends ThemeExtension<PeculeColors> {
  const PeculeColors({
    required this.textReading,
    required this.textLesson,
    required this.textMuted,
    required this.trace,
    required this.gain,
    required this.loss,
    required this.alert,
    required this.stock,
    required this.etf,
    required this.crypto,
  });

  static const dark = PeculeColors(
    textReading: PeculePalette.textReading,
    textLesson: PeculePalette.textLesson,
    textMuted: PeculePalette.textMuted,
    trace: PeculePalette.trace,
    gain: PeculePalette.gain,
    loss: PeculePalette.loss,
    alert: PeculePalette.alert,
    stock: PeculePalette.stock,
    etf: PeculePalette.etf,
    crypto: PeculePalette.crypto,
  );

  final Color textReading;
  final Color textLesson;
  final Color textMuted;
  final Color trace;
  final Color gain;
  final Color loss;
  final Color alert;
  final Color stock;
  final Color etf;
  final Color crypto;

  @override
  PeculeColors copyWith({
    Color? textReading,
    Color? textLesson,
    Color? textMuted,
    Color? trace,
    Color? gain,
    Color? loss,
    Color? alert,
    Color? stock,
    Color? etf,
    Color? crypto,
  }) {
    return PeculeColors(
      textReading: textReading ?? this.textReading,
      textLesson: textLesson ?? this.textLesson,
      textMuted: textMuted ?? this.textMuted,
      trace: trace ?? this.trace,
      gain: gain ?? this.gain,
      loss: loss ?? this.loss,
      alert: alert ?? this.alert,
      stock: stock ?? this.stock,
      etf: etf ?? this.etf,
      crypto: crypto ?? this.crypto,
    );
  }

  @override
  PeculeColors lerp(PeculeColors? other, double t) {
    if (other == null) return this;
    return PeculeColors(
      textReading: Color.lerp(textReading, other.textReading, t)!,
      textLesson: Color.lerp(textLesson, other.textLesson, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      trace: Color.lerp(trace, other.trace, t)!,
      gain: Color.lerp(gain, other.gain, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
      stock: Color.lerp(stock, other.stock, t)!,
      etf: Color.lerp(etf, other.etf, t)!,
      crypto: Color.lerp(crypto, other.crypto, t)!,
    );
  }
}

extension PeculeColorsContext on BuildContext {
  PeculeColors get peculeColors =>
      Theme.of(this).extension<PeculeColors>() ?? PeculeColors.dark;
}
