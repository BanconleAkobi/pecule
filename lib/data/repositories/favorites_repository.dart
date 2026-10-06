import 'package:pecule/core/clock.dart';
import 'package:pecule/data/local/favorite_dao.dart';

class FavoritesRepository {
  FavoritesRepository({required this._favorites, required this._clock});

  final FavoriteDao _favorites;
  final Clock _clock;

  Future<List<String>> getFavoriteAssetIds() => _favorites.findAssetIds();

  Future<void> add(String assetId) =>
      _favorites.add(assetId, addedAt: _clock.now());

  Future<void> remove(String assetId) => _favorites.remove(assetId);
}
