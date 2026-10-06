import 'package:pecule/data/iso_day.dart';
import 'package:pecule/data/local/sql_values.dart';
import 'package:pecule/domain/models/dca_plan.dart';
import 'package:pecule/domain/models/saved_simulation.dart';
import 'package:sqflite/sqflite.dart';

class SavedSimulationDao {
  SavedSimulationDao(this._database);

  static const _table = 'saved_simulation';

  final Database _database;

  /// Renvoie l'identifiant donné par la base.
  Future<int> insert({
    required String assetId,
    required DcaPlan plan,
    required DateTime createdAt,
  }) {
    return _database.insert(_table, {
      'asset_id': assetId,
      'periodic_amount_eur': plan.periodicAmountEur,
      'frequency': plan.frequency.name,
      'start_date': formatIsoDay(plan.startDate),
      'created_at': toMillis(createdAt),
    });
  }

  /// La plus récente en premier, comme dans la maquette.
  Future<List<SavedSimulation>> findAll() async {
    final rows = await _database.query(_table, orderBy: 'created_at DESC');
    return rows.map(_fromRow).toList();
  }

  SavedSimulation _fromRow(Map<String, Object?> row) => SavedSimulation(
    id: row['id']! as int,
    assetId: row['asset_id']! as String,
    plan: DcaPlan(
      periodicAmountEur: readDouble(row['periodic_amount_eur']),
      frequency: DcaFrequency.values.byName(row['frequency']! as String),
      startDate: parseIsoDay(row['start_date']! as String),
    ),
    createdAt: fromMillis(row['created_at']),
  );
}
