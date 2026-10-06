import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:pecule/features/favorites/favorites_provider.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  late FakeFavoritesRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeFavoritesRepository();
    container = ProviderContainer(
      overrides: [favoritesRepositoryProvider.overrideWithValue(repository)],
    );
  });
  tearDown(() => container.dispose());

  test('ajoute un favori, l\'enregistre et signale un ajout', () async {
    await container.read(favoritesProvider.future);

    final isAdded = await container
        .read(favoritesProvider.notifier)
        .toggle('AAPL');

    expect(isAdded, isTrue);
    expect(container.read(favoritesProvider).value, {'AAPL'});
    expect(repository.assetIds, ['AAPL']);
  });

  test('retire un favori déjà présent et signale un retrait', () async {
    repository.assetIds.add('AAPL');
    await container.read(favoritesProvider.future);

    final isAdded = await container
        .read(favoritesProvider.notifier)
        .toggle('AAPL');

    expect(isAdded, isFalse);
    expect(container.read(favoritesProvider).value, isEmpty);
    expect(repository.assetIds, isEmpty);
  });
}
