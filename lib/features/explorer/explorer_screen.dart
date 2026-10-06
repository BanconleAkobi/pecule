import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:pecule/app/theme/pecule_spacing.dart';
import 'package:pecule/app/widgets/toast.dart';
import 'package:pecule/data/catalogue.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/features/asset_detail/asset_detail_screen.dart';
import 'package:pecule/features/explorer/explorer_query.dart';
import 'package:pecule/features/explorer/widgets/asset_row.dart';
import 'package:pecule/features/explorer/widgets/explorer_empty_states.dart';
import 'package:pecule/features/explorer/widgets/filter_chips.dart';
import 'package:pecule/features/explorer/widgets/search_field.dart';
import 'package:pecule/features/favorites/favorites_provider.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(explorerQueryProvider.notifier).search('');
  }

  Future<void> _toggleFavorite(Asset asset) async {
    final isAdded = await ref.read(favoritesProvider.notifier).toggle(asset.id);
    if (!mounted) return;
    showToast(
      context,
      isAdded ? 'Ajouté à tes favoris' : 'Retiré de tes favoris',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(explorerQueryProvider);
    final favoriteIds = ref.watch(favoritesProvider).value ?? const {};
    final isOffline = ref.watch(isOfflineProvider).value ?? false;
    final assets = filterCatalogue(
      catalogue,
      query,
      favoriteAssetIds: favoriteIds,
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: PeculeSpacing.tabScreen,
        children: [
          Text('Explorer', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 16),
          SearchField(
            controller: _searchController,
            onChanged: ref.read(explorerQueryProvider.notifier).search,
            onClear: _clearSearch,
          ),
          const SizedBox(height: 14),
          FilterChips(
            selected: query.filter,
            onSelected: ref.read(explorerQueryProvider.notifier).filterBy,
          ),
          const SizedBox(height: 22),
          Text(
            _listCaption(assetCount: assets.length, isOffline: isOffline),
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          if (assets.isEmpty && query.filter == ExplorerFilter.favorites)
            if (query.hasText)
              NoResult(query: query.text.trim(), onClear: _clearSearch)
            else
              const NoFavorite()
          else if (assets.isEmpty)
            NoResult(query: query.text.trim(), onClear: _clearSearch)
          else
            for (final asset in assets)
              AssetRow(
                asset: asset,
                isFavorite: favoriteIds.contains(asset.id),
                onFavoritePressed: () => _toggleFavorite(asset),
                onTap: () =>
                    Navigator.of(context)
                        .push(AssetDetailScreen.route(asset.id)),
              ),
        ],
      ),
    );
  }

  String _listCaption({required int assetCount, required bool isOffline}) {
    final count = assetCount == 1 ? '1 ACTIF' : '$assetCount ACTIFS';
    final period = isOffline ? 'DERNIERS COURS CONNUS' : 'VARIATION SUR 1 AN';
    return '$count · $period';
  }
}
