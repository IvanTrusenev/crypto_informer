import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/core/formatters/currency_formatter.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/watchlist/presentation/widgets/animated_watchlist_icon_button.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Карточка монеты: аватар, имя, тикер, 24ч %, цена, Cap, Vol, избранное.
class CoinListTile extends StatelessWidget {
  const CoinListTile({
    required this.asset,
    required this.priceText,
    required this.inWatchlist,
    required this.l10n,
    required this.onTap,
    required this.onToggleStar,
    this.dense = false,
    super.key,
  });

  final CoinEntity asset;
  final String priceText;
  final bool inWatchlist;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onToggleStar;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;
    final finance = context.financeColors;
    final localeName = Localizations.localeOf(context).toString();

    final change = asset.priceChangePercent24h;
    final changeColor = change >= 0
        ? finance.pricePositive
        : finance.priceNegative;
    final changeStr = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';

    final cap = asset.marketCapUsd;
    final vol = asset.totalVolumeUsd;

    final vertPad = dense ? 8.0 : 12.0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: vertPad,
        ),
        child: Row(
          children: [
            Hero(
              tag: 'coin_avatar_${asset.id}',
              child: CircleAvatar(
                radius: dense ? 18 : 22,
                backgroundColor: scheme.surfaceContainerHighest,
                backgroundImage: asset.imageUrl != null
                    ? NetworkImage(asset.imageUrl!)
                    : null,
                child: asset.imageUrl == null
                    ? Text(
                        asset.symbol.length >= 2
                            ? asset.symbol.substring(0, 2)
                            : asset.symbol,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          style: textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        priceText,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AnimatedWatchlistIconButton(
                        isInWatchlist: inWatchlist,
                        onPressed: onToggleStar,
                        tooltip: inWatchlist
                            ? l10n.tooltipWatchlistRemove
                            : l10n.tooltipWatchlistAdd,
                        visualDensity: dense
                            ? VisualDensity.compact
                            : VisualDensity.standard,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        asset.symbol,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        changeStr,
                        style: textTheme.bodyMedium?.copyWith(
                          color: changeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (cap != null || vol != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (cap != null)
                          Text(
                            '${l10n.marketCapShort} '
                            '${CurrencyFormatter.formatCompactMetric(
                              cap,
                              localeName: localeName,
                              currencySymbol: r'$',
                            )}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        if (cap != null && vol != null)
                          const SizedBox(width: 12),
                        if (vol != null)
                          Text(
                            '${l10n.marketVolumeShort} '
                            '${CurrencyFormatter.formatCompactMetric(
                              vol,
                              localeName: localeName,
                              currencySymbol: r'$',
                            )}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
