import 'package:pecule/domain/models/dca_plan.dart';

/// Seuls les paramètres sont gardés : le résultat est recalculé à chaque
/// ouverture, avec les cours du moment.
class SavedSimulation {
  const SavedSimulation({
    required this.id,
    required this.assetId,
    required this.plan,
    required this.createdAt,
  });

  final int id;
  final String assetId;
  final DcaPlan plan;
  final DateTime createdAt;
}
