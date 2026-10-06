import 'package:flutter/material.dart';
import 'package:pecule/features/explorer/explorer_query.dart';
import 'package:pecule/features/explorer/widgets/favorite_button.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ExplorerFilter selected;
  final ValueChanged<ExplorerFilter> onSelected;

  static String labelOf(ExplorerFilter filter) => switch (filter) {
    ExplorerFilter.all => 'Tous',
    ExplorerFilter.stocks => 'Actions',
    ExplorerFilter.etfs => 'ETF',
    ExplorerFilter.cryptos => 'Cryptos',
    ExplorerFilter.favorites => '$filledHeart Favoris',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in ExplorerFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: labelOf(filter),
                isSelected: filter == selected,
                onTap: () => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.onSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? colorScheme.onSurface : colorScheme.outline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? colorScheme.surface : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
