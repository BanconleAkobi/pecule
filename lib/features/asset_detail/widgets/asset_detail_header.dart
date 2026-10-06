import 'package:flutter/material.dart';
import 'package:pecule/app/widgets/explain_sheet.dart';
import 'package:pecule/app/widgets/signed_change.dart';
import 'package:pecule/core/formatters.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/features/asset_detail/asset_detail_texts.dart';
import 'package:pecule/features/asset_detail/asset_detail_view.dart';

/// Nom, cours en euros et variation de la période. Pendant la lecture au
/// doigt, ce sont le cours et la variation du point touché. La variation,
/// soulignée en pointillés, s'ouvre en phrase simple.
class AssetDetailHeader extends StatelessWidget {
  const AssetDetailHeader({
    super.key,
    required this.view,
    required this.reading,
  });

  final AssetDetailView view;
  final ChartReading? reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reading = this.reading;
    final scrubbedDay = reading?.scrubbedDay;
    final caption = scrubbedDay == null
        ? periodCaption(view.period)
        : 'au ${formatDay(scrubbedDay)}';
    final change = reading?.change;
    final updatedAt = view.updatedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(view.asset.name, style: theme.textTheme.titleMedium),
        Text(
          reading == null
              ? SignedChange.unavailableText
              : formatPriceEur(reading.priceEur),
          style: theme.textTheme.displayMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Row(
          children: [
            if (change != null)
              GestureDetector(
                onTap: () => _explain(context, change, scrubbedDay != null),
                child: SignedChange(
                  change: change,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              caption,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (view.isStale && updatedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              formatUpdatedAt(updatedAt),
              style: theme.textTheme.labelSmall,
            ),
          ),
      ],
    );
  }

  void _explain(BuildContext context, Computed<double> change, bool isScrub) {
    if (change case Available(:final value)) {
      showExplainSheet(
        context,
        title: explainChangeTitle(value),
        text: explainChangeText(
          assetName: view.asset.name,
          change: value,
          period: view.period,
          isScrubbing: isScrub,
        ),
      );
    }
  }
}
