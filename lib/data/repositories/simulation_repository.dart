import 'package:pecule/core/clock.dart';
import 'package:pecule/data/local/saved_simulation_dao.dart';
import 'package:pecule/domain/models/dca_plan.dart';
import 'package:pecule/domain/models/saved_simulation.dart';

class SimulationRepository {
  SimulationRepository({required this._simulations, required this._clock});

  final SavedSimulationDao _simulations;
  final Clock _clock;

  /// La plus récente en premier.
  Future<List<SavedSimulation>> getSavedSimulations() => _simulations.findAll();

  /// Renvoie l'identifiant de la simulation enregistrée.
  Future<int> save({required String assetId, required DcaPlan plan}) {
    return _simulations.insert(
      assetId: assetId,
      plan: plan,
      createdAt: _clock.now(),
    );
  }
}
