import 'package:flutter/material.dart';
import 'package:pecule/app/theme/pecule_colors.dart';
import 'package:pecule/app/widgets/signed_change.dart';
import 'package:pecule/domain/computed.dart';
import 'package:pecule/domain/models/currency_effect.dart';
import 'package:pecule/features/asset_detail/asset_detail_texts.dart';

/// « Dollar ou euro ? » : la performance dans la devise de l'actif et celle
/// que voit un investisseur en euros (cahier des charges, section 8.4).
class CurrencyBlock extends StatelessWidget {
  const CurrencyBlock({super.key, required this.effect});

  final CurrencyEffect effect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dollar ou euro ?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Performance(
                  label: 'En dollars',
                  change: Available(effect.performanceUsd),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Performance(
                  label: 'Pour toi, en euros',
                  change: Available(effect.performanceEur),
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            currencyEffectText(effect),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: context.peculeColors.textReading,
            ),
          ),
        ],
      ),
    );
  }
}

class _Performance extends StatelessWidget {
  const _Performance({
    required this.label,
    required this.change,
    this.isHighlighted = false,
  });

  final String label;
  final Computed<double> change;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: isHighlighted
            ? Border.all(color: colorScheme.primary, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SignedChange(
              change: change,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
