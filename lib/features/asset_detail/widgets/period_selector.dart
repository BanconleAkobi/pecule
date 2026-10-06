import 'package:flutter/material.dart';
import 'package:pecule/domain/models/chart_period.dart';
import 'package:pecule/features/asset_detail/asset_detail_texts.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final period in ChartPeriod.values)
          Semantics(
            button: true,
            selected: period == selected,
            child: GestureDetector(
              onTap: () => onSelected(period),
              child: Container(
                width: 58,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: period == selected
                      ? colorScheme.surfaceContainerHigh
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  periodButtonLabel(period),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: period == selected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
