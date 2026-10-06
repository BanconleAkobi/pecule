import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/app/dependencies.dart';

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

/// Identifiants des actifs en favori, partagés par l'Explorer et la fiche.
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final ids = await ref
        .watch(favoritesRepositoryProvider)
        .getFavoriteAssetIds();
    return ids.toSet();
  }

  /// Ajoute ou retire [assetId]. L'écran change tout de suite, la base
  /// suit. Renvoie vrai pour un ajout, pour choisir le message du toast.
  Future<bool> toggle(String assetId) async {
    final current = state.value ?? const <String>{};
    final isAdding = !current.contains(assetId);
    state = AsyncData(
      isAdding ? {...current, assetId} : ({...current}..remove(assetId)),
    );

    final repository = ref.read(favoritesRepositoryProvider);
    if (isAdding) {
      await repository.add(assetId);
    } else {
      await repository.remove(assetId);
    }
    return isAdding;
  }
}
