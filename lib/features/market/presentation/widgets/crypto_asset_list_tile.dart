import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/watchlist/presentation/widgets/animated_watchlist_icon_button.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Число колонок сетки карточек по ширине контента.
int marketListCrossAxisCount(double width) {
  if (width >= 1200) return 4;
  if (width >= 900) return 3;
  if (width >= 600) return 2;
  return 1;
}

String _compactNumber(double value) {
  if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(2)}T';
  if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(2)}B';
  if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
  if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}

/// Карточка монеты: аватар, имя, тикер, 24ч %, цена, Cap, Vol, избранное.
class CryptoAssetListTile extends StatelessWidget {
  const CryptoAssetListTile({
    required this.asset,
    required this.priceText,
    required this.inWatchlist,
    required this.l10n,
    required this.onTap,
    required this.onToggleStar,
    this.dense = false,
    super.key,
  });

  final CryptoAssetEntity asset;
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
                            'Cap \$${_compactNumber(cap)}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        if (cap != null && vol != null)
                          const SizedBox(width: 12),
                        if (vol != null)
                          Text(
                            'Vol \$${_compactNumber(vol)}',
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
