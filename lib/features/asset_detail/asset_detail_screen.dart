import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/app/labels.dart';
import 'package:pecule/app/widgets/error_state.dart';
import 'package:pecule/app/widgets/toast.dart';
import 'package:pecule/data/catalogue.dart';
import 'package:pecule/data/remote/api_exceptions.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/features/asset_detail/asset_detail_providers.dart';
import 'package:pecule/features/asset_detail/asset_detail_view.dart';
import 'package:pecule/features/asset_detail/widgets/asset_detail_header.dart';
import 'package:pecule/features/asset_detail/widgets/currency_block.dart';
import 'package:pecule/features/asset_detail/widgets/explain_cards.dart';
import 'package:pecule/features/asset_detail/widgets/period_selector.dart';
import 'package:pecule/features/asset_detail/widgets/price_chart.dart';
import 'package:pecule/features/asset_detail/widgets/stability_card.dart';
import 'package:pecule/features/explorer/widgets/favorite_button.dart';
import 'package:pecule/features/favorites/favorites_provider.dart';

/// La fiche d'un actif : l'écran qui porte la pédagogie (cahier des charges,
/// section 4.4). Elle s'ouvre par-dessus l'onglet courant.
class AssetDetailScreen extends ConsumerStatefulWidget {
  const AssetDetailScreen({super.key, required this.assetId});

  final String assetId;

  static Route<void> route(String assetId) =>
      MaterialPageRoute(builder: (_) => AssetDetailScreen(assetId: assetId));

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

// La période et le point touché ne concernent que cet écran ouvert : ils
// vivent dans son état, et repartent de 1A à chaque ouverture comme dans la
// maquette.
class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  var _period = ChartPeriod.oneYear;
  int? _scrubIndex;

  Future<void> _toggleFavorite() async {
    final isAdded = await ref
        .read(favoritesProvider.notifier)
        .toggle(widget.assetId);
    if (!mounted) return;
    showToast(
      context,
      isAdded ? 'Ajouté à tes favoris' : 'Retiré de tes favoris',
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = catalogueById[widget.assetId]!;
    final view = ref.watch(
      assetDetailViewProvider((assetId: widget.assetId, period: _period)),
    );
    final isFavorite =
        ref.watch(favoritesProvider).value?.contains(asset.id) ?? false;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                _TopBar(
                  caption: '${asset.symbol} · ${assetTypeLabel(asset.type)}',
                  isFavorite: isFavorite,
                  onFavoritePressed: _toggleFavorite,
                ),
                ...switch (view) {
                  AsyncData(value: final view) => _content(view),
                  AsyncError() => [
                    ErrorState(
                      message: 'Impossible d\'afficher cet actif.',
                      onRetry: () =>
                          ref.invalidate(assetHistoryProvider(widget.assetId)),
                    ),
                  ],
                  _ => [const _ChartLoading()],
                },
              ],
            ),
            const _AddToPortfolioButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(AssetDetailView view) {
    if (!view.hasPrices) return [_NoPrices(view: view)];

    final currencyEffect = view.currencyEffect;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: AssetDetailHeader(
          view: view,
          reading: readChart(view, scrubIndex: _scrubIndex),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: PriceChart(
          points: view.points,
          scrubIndex: _scrubIndex,
          onScrub: (index) => setState(() => _scrubIndex = index),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: PeriodSelector(
          selected: _period,
          onSelected: (period) => setState(() {
            _period = period;
            _scrubIndex = null;
          }),
        ),
      ),
      if (currencyEffect case Available(value: final effect)) ...[
        const SizedBox(height: 28),
        CurrencyBlock(effect: effect),
      ],
      const SizedBox(height: 12),
      StabilityCard(stability: view.stability),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
        child: Text(
          'Ça veut dire quoi ?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ExplainCards(view: view),
      ),
    ];
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.caption,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  final String caption;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circle = BoxDecoration(
      shape: BoxShape.circle,
      color: theme.colorScheme.surfaceContainer,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: circle,
            child: IconButton(
              tooltip: 'Retour',
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Text(
            caption,
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: circle,
            alignment: Alignment.center,
            child: FavoriteButton(
              isFavorite: isFavorite,
              onPressed: onFavoritePressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: PriceChart.chartHeight,
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Chargement de l\'historique…',
        style: theme.textTheme.labelSmall,
      ),
    );
  }
}

/// Aucun cours : jamais téléchargé hors connexion, ou l'API a échoué. Hors
/// connexion, c'est un état vide explicite plutôt qu'une erreur (cahier des
/// charges, section 7.4).
class _NoPrices extends ConsumerWidget {
  const _NoPrices({required this.view});

  final AssetDetailView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = view.refreshError;
    final message = switch (error) {
      NetworkException() => 'Pas encore de cours pour cet actif. Connecte-toi pour les télécharger.',
      RateLimitException() =>
        'Trop de demandes pour le moment. Réessaie dans une minute.',
      _ => 'Impossible de charger l\'historique.',
    };
    return ErrorState(
      message: message,
      onRetry: () => ref.invalidate(assetHistoryProvider(view.asset.id)),
    );
  }
}

class _AddToPortfolioButton extends StatelessWidget {
  const _AddToPortfolioButton();

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [background, background, background.withValues(alpha: 0)],
            stops: const [0, 0.62, 1],
          ),
        ),
        // TODO(F-ACH-01): ouvrir le formulaire d'achat fictif (sprint S4).
        child: const FilledButton(
          onPressed: null,
          child: Text('Ajouter à mon portefeuille'),
        ),
      ),
    );
  }
}
