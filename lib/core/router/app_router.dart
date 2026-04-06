import 'package:crypto_informer/core/shell/scaffold_with_nav_bar.dart';
import 'package:crypto_informer/features/market/presentation/pages/coin_detail_page.dart';
import 'package:crypto_informer/features/market/presentation/pages/market_page.dart';
import 'package:crypto_informer/features/settings/presentation/pages/settings_page.dart';
import 'package:crypto_informer/features/watchlist/presentation/pages/watchlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _marketShellKey = GlobalKey<NavigatorState>(debugLabel: 'marketShell');
final _watchlistShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'watchlistShell');
final _settingsShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'settingsShell');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/market',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _marketShellKey,
            routes: [
              GoRoute(
                path: '/market',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const MarketPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'coin/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return CoinDetailPage(coinId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _watchlistShellKey,
            routes: [
              GoRoute(
                path: '/watchlist',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const WatchlistPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsShellKey,
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const SettingsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
