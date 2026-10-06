import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/features/asset_detail/asset_detail_texts.dart';
import 'package:pecule/features/asset_detail/asset_detail_view.dart';

/// Les cartes « Ça veut dire quoi ? » : chaque indicateur expliqué avec les
/// chiffres de cet actif précis (cahier des charges, section 4.4).
class ExplainCards extends StatelessWidget {
  const ExplainCards({super.key, required this.view});

  final AssetDetailView view;

  @override
  Widget build(BuildContext context) {
    final asset = view.asset;
    final performance = switch (view.yearChange) {
      Available(:final value) => performanceCardText(
        assetName: asset.name,
        yearChange: value,
      ),
      Unavailable() => notEnoughHistory,
    };
    final (volatility, drawdown) = switch (view.stability) {
      Available(value: final score) => (
        volatilityCardText(
          assetName: asset.name,
          type: asset.type,
          volatility: score.volatility,
        ),
        drawdownCardText(maxDrawdown: score.maxDrawdown),
      ),
      Unavailable() => (notEnoughHistory, notEnoughHistory),
    };

    return Column(
      children: [
        _ExplainCard(title: 'Performance sur 1 an', text: performance),
        const SizedBox(height: 8),
        _ExplainCard(title: 'Volatilité', text: volatility),
        const SizedBox(height: 8),
        _ExplainCard(title: 'Plus forte baisse', text: drawdown),
      ],
    );
  }
}

class _ExplainCard extends StatefulWidget {
  const _ExplainCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  State<_ExplainCard> createState() => _ExplainCardState();
}

class _ExplainCardState extends State<_ExplainCard> {
  // Un huitième de tour (45°) : le « + » devient un « × » carte ouverte.
  static const _openTurns = 0.125;
  static const _toggleDuration = Duration(milliseconds: 250);

  var _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isOpen = !_isOpen),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 15),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? _openTurns : 0,
                    duration: _toggleDuration,
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Text(
                widget.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.5,
                  height: 1.55,
                  color: context.peculeColors.textReading,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
