import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pecule/app/dependencies.dart';
import 'package:pecule/app/navigation/app_tab.dart';
import 'package:pecule/app/navigation/pecule_tab_bar.dart';
import 'package:pecule/app/widgets/offline_banner.dart';
import 'package:pecule/features/explorer/explorer_screen.dart';
import 'package:pecule/features/learn/learn_screen.dart';
import 'package:pecule/features/market/market_providers.dart';
import 'package:pecule/features/patrimoine/patrimoine_screen.dart';
import 'package:pecule/features/simulator/simulator_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _currentTab = AppTab.patrimoine;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _OfflineBannerSlot(),
              Expanded(
                // L'indexedstack garde les quatre onglets construits : chacun conserve
                // son état et sa position de défilement quand on change d'onglet.
                child: IndexedStack(
                  index: _currentTab.index,
                  children: [
                    for (final tab in AppTab.values) _TabScreen(tab: tab),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: PeculeTabBar(
          selectedTab: _currentTab,
          onTabSelected: (tab) => setState(() => _currentTab = tab),
        ),
      ),
    );
  }
}

/// Le bandeau hors connexion, commun à tous les onglets. La date affichée est
/// celle des derniers taux reçus, rafraîchis à chaque ouverture.
class _OfflineBannerSlot extends ConsumerWidget {
  const _OfflineBannerSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider).value ?? false;
    if (!isOffline) return const SizedBox.shrink();
    final rates = ref.watch(eurUsdRatesProvider).value;
    return OfflineBanner(dataUpdatedAt: rates?.updatedAt);
  }
}

class _TabScreen extends StatelessWidget {
  const _TabScreen({required this.tab});

  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      AppTab.patrimoine => const PatrimoineScreen(),
      AppTab.explorer => const ExplorerScreen(),
      AppTab.learn => const LearnScreen(),
      AppTab.simulator => const SimulatorScreen(),
    };
  }
}
