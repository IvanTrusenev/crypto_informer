import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CoinDetailPage extends ConsumerWidget {
  const CoinDetailPage({required this.coinId, super.key});

  final String coinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: r'$',
      decimalDigits: 2,
    );
    final async = ref.watch(coinDetailProvider(coinId));
    final watchlistAsync = ref.watch(watchlistProvider);
    final inList = (watchlistAsync.valueOrNull ?? []).contains(coinId);

    return Scaffold(
      appBar: AppBar(
        title: async.maybeWhen(
          data: (d) => Text(d.name),
          orElse: () => Text(l10n.coinTitleFallback),
        ),
        actions: [
          IconButton(
            tooltip: inList
                ? l10n.tooltipWatchlistRemove
                : l10n.tooltipWatchlistAdd,
            icon: Icon(
              inList ? Icons.star : Icons.star_border,
              color: inList ? context.theme.colorScheme.primary : null,
            ),
            onPressed: () =>
                ref.read(watchlistProvider.notifier).toggle(coinId),
          ),
        ],
      ),
      body: async.when(
        data: (detail) {
          final change = detail.priceChangePercent24h;
          final changeColor = change != null && change >= 0
              ? Colors.green.shade700
              : Colors.red.shade700;
          final percentLabel = change == null
              ? ''
              : l10n.coinChange24h(
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}',
                );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (detail.imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      detail.imageUrl!,
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                detail.symbol,
                textAlign: TextAlign.center,
                style: context.theme.textTheme.titleLarge,
              ),
              if (detail.currentPriceUsd != null) ...[
                const SizedBox(height: 8),
                Text(
                  priceFormat.format(detail.currentPriceUsd),
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.headlineSmall,
                ),
              ],
              if (change != null) ...[
                const SizedBox(height: 4),
                Text(
                  percentLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (detail.description != null &&
                  detail.description!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.coinSectionDescription,
                  style: context.theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  detail.description!,
                  style: context.theme.textTheme.bodyMedium,
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              localizedErrorMessage(l10n, e),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
