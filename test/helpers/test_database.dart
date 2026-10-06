import 'package:pecule/data/local/pecule_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Base SQLite en mémoire, sur l'ordinateur, sans téléphone. La fermer en fin
/// de test : la suivante repart d'une base vide.
Future<Database> openTestDatabase() {
  sqfliteFfiInit();
  return openPeculeDatabase(databaseFactoryFfi, inMemoryDatabasePath);
}
