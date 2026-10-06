import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/test_database.dart';

void main() {
  late Database database;
  late ProviderContainer container;

  setUp(() async {
    database = await openTestDatabase();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('assemble tous les repositories à partir de la base fournie', () {
    expect(
      () => container.read(priceHistoryRepositoryProvider),
      returnsNormally,
    );
    expect(() => container.read(fxRateRepositoryProvider), returnsNormally);
    expect(() => container.read(favoritesRepositoryProvider), returnsNormally);
    expect(() => container.read(portfolioRepositoryProvider), returnsNormally);
    expect(() => container.read(simulationRepositoryProvider), returnsNormally);
    expect(() => container.read(profileRepositoryProvider), returnsNormally);
    expect(
      () => container.read(lessonProgressRepositoryProvider),
      returnsNormally,
    );
  });

  // Riverpod met en pause un provider que personne n'écoute : on l'écoute,
  // comme le fera le bandeau hors connexion.
  test('démarre en ligne', () async {
    final subscription = container.listen(
      isOfflineProvider.future,
      (previous, next) {},
    );

    expect(await subscription.read(), isFalse);
  });

  test('refuse de fonctionner sans base ouverte dans main', () {
    final withoutDatabase = ProviderContainer();
    addTearDown(withoutDatabase.dispose);

    expect(() => withoutDatabase.read(databaseProvider), throwsA(anything));
  });
}
