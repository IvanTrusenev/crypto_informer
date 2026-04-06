import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/network/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Оболочка с нижней навигацией для трёх основных разделов приложения.
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final connectivity = ref.watch(connectivityListProvider);
    final showOfflineBanner = connectivity.maybeWhen(
      data: listIndicatesOffline,
      orElse: () => false,
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showOfflineBanner)
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.offlineNoConnection,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.show_chart_outlined),
                selectedIcon: const Icon(Icons.show_chart),
                label: l10n.navMarket,
              ),
              NavigationDestination(
                icon: const Icon(Icons.star_outline),
                selectedIcon: const Icon(Icons.star),
                label: l10n.navWatchlist,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.navSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
