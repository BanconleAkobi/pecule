enum StabilityLevel { agitated, moderate, stable }

/// Garde les valeurs brutes et les deux notes : l'écran les affiche dans le
/// détail du score, pour que l'utilisateur comprenne d'où il vient.
class StabilityScore {
  const StabilityScore({
    required this.volatility,
    required this.maxDrawdown,
    required this.volatilityNote,
    required this.drawdownNote,
    required this.value,
    required this.level,
  });

  final double volatility;
  final double maxDrawdown;
  final double volatilityNote;
  final double drawdownNote;
  final int value;
  final StabilityLevel level;
}
