import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/features/alerts/presentation/cubit/price_alert_cubit.dart';
import 'package:crypto_informer/features/alerts/presentation/widgets/in_app_notification.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
/// Оболочка с нижней навигацией для трёх основных разделов приложения.
class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  final _connectivity = Connectivity();
  late final Stream<List<ConnectivityResult>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _connectivity.onConnectivityChanged;
  }

  void _onMarketStateChanged(BuildContext context, MarketState state) {
    if (state is! MarketLoaded) return;
    final alertCubit = context.read<PriceAlertCubit>();
    final triggered = alertCubit.checkAndConsume(state.assets);
    if (triggered.isEmpty) return;

    final l10n = context.l10n;
    final priceFormat = context.usdCurrencyFormat;

    for (final alert in triggered) {
      final body = alert.isAbove
          ? l10n.alertTriggeredAbove(priceFormat.format(alert.thresholdPrice))
          : l10n.alertTriggeredBelow(priceFormat.format(alert.thresholdPrice));

      InAppNotification.show(
        context,
        title: l10n.alertTriggeredTitle(alert.coinName),
        body: body,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<MarketCubit, MarketState>(
      listener: _onMarketStateChanged,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<List<ConnectivityResult>>(
              stream: _stream,
              builder: (context, snapshot) {
                final isOffline =
                    snapshot.hasData &&
                    snapshot.data!.contains(ConnectivityResult.none);
                if (!isOffline) return const SizedBox.shrink();
                return Material(
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.offlineNoConnection,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            NavigationBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: widget.navigationShell.goBranch,
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
      ),
    );
  }
}
