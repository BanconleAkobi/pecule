import 'package:pecule/data/local/database_schema.dart';
import 'package:sqflite/sqflite.dart';

const databaseFileName = 'pecule.db';

/// [factory] et [path] sont fournis par l'appelant : la vraie base sur le
/// téléphone, une base en mémoire dans les tests.
Future<Database> openPeculeDatabase(DatabaseFactory factory, String path) {
  return factory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: databaseVersion,
      onCreate: _createSchema,
    ),
  );
}

Future<void> _createSchema(Database database, int version) async {
  final batch = database.batch();
  for (final statement in schemaStatements) {
    batch.execute(statement);
  }
  await batch.commit(noResult: true);
}

/// « Vider le cache » (cahier des charges, section 7.3) : les cours, les taux
/// et l'état de synchronisation. Les données de l'utilisateur restent.
Future<void> clearCache(Database database) async {
  await database.transaction((transaction) async {
    for (final table in cacheTables) {
      await transaction.delete(table);
    }
  });
}
