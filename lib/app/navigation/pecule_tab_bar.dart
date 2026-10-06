import 'package:flutter/material.dart';
import 'package:pecule/app/navigation/app_tab.dart';
import 'package:pecule/app/theme/pecule_colors.dart';

class PeculeTabBar extends StatelessWidget {
  const PeculeTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (final tab in AppTab.values)
                Expanded(
                  child: _TabButton(
                    tab: tab,
                    isSelected: tab == selectedTab,
                    onTap: () => onTabSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  static const _indicatorDuration = Duration(milliseconds: 250);

  final AppTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = isSelected
        ? theme.colorScheme.onSurface
        : context.peculeColors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              AnimatedContainer(
                duration: _indicatorDuration,
                width: isSelected ? 22 : 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                tab.label,
                style: theme.textTheme.labelMedium?.copyWith(color: labelColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
