import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/app/labels.dart';
import 'package:pecule/app/widgets/asset_avatar.dart';
import 'package:pecule/app/widgets/signed_change.dart';
import 'package:pecule/app/widgets/skeleton_block.dart';
import 'package:pecule/core/formatters.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/asset.dart';
import 'package:pecule/domain/models/asset_quote.dart';
import 'package:pecule/features/explorer/widgets/favorite_button.dart';
import 'package:pecule/features/market/market_providers.dart';

class AssetRow extends ConsumerWidget {
  const AssetRow({
    super.key,
    required this.asset,
    required this.isFavorite,
    required this.onFavoritePressed,
    this.onTap,
  });

  final Asset asset;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quote = ref.watch(assetQuoteProvider(asset.id));

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            AssetAvatar(asset: asset),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${asset.symbol} · ${assetTypeLabel(asset.type)}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            switch (quote) {
              AsyncData(value: final quote) => _QuoteColumn(quote: quote),
              AsyncError() => const _QuoteColumn(quote: _unavailableQuote),
              _ => const _QuotePlaceholder(),
            },
            FavoriteButton(
              isFavorite: isFavorite,
              onPressed: onFavoritePressed,
            ),
          ],
        ),
      ),
    );
  }
}

const _unavailableQuote = AssetQuote(
  latestPriceEur: Unavailable(UnavailableReason.notEnoughPrices),
  yearChange: Unavailable(UnavailableReason.notEnoughPrices),
);

class _QuoteColumn extends StatelessWidget {
  const _QuoteColumn({required this.quote});

  final AssetQuote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = switch (quote.latestPriceEur) {
      Available(:final value) => formatPriceEur(value),
      Unavailable() => SignedChange.unavailableText,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          price,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 15,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 3),
        SignedChange(
          change: quote.yearChange,
          style: theme.textTheme.bodySmall?.copyWith(height: 1.2),
        ),
      ],
    );
  }
}

class _QuotePlaceholder extends StatelessWidget {
  const _QuotePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SkeletonBlock(width: 64, height: 12),
        SizedBox(height: 8),
        SkeletonBlock(width: 44, height: 9),
      ],
    );
  }
}
