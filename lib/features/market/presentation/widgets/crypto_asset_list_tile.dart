import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/watchlist/presentation/widgets/animated_watchlist_icon_button.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Число колонок сетки карточек по ширине контента (как на рынке / в избранном).
int marketListCrossAxisCount(double width) {
  if (width >= 1200) {
    return 4;
  }
  if (width >= 900) {
    return 3;
  }
  if (width >= 600) {
    return 2;
  }
  return 1;
}

/// Строка/карточка монеты: аватар, имя, 24ч %, цена, избранное.
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

  final CryptoAsset asset;
  final String priceText;
  final bool inWatchlist;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onToggleStar;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finance = context.financeColors;
    final change = asset.priceChangePercent24h;
    final changeColor = change >= 0
        ? finance.pricePositive
        : finance.priceNegative;
    final changeStr = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';

    return ListTile(
      dense: dense,
      visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
      onTap: onTap,
      leading: Hero(
        tag: 'coin_avatar_${asset.id}',
        child: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
      title: Text(asset.name),
      subtitle: Text(
        l10n.marketAssetSubtitle(asset.symbol, changeStr),
        style: theme.textTheme.bodySmall?.copyWith(color: changeColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(priceText, style: theme.textTheme.titleMedium),
          AnimatedWatchlistIconButton(
            isInWatchlist: inWatchlist,
            onPressed: onToggleStar,
            tooltip: inWatchlist
                ? l10n.tooltipWatchlistRemove
                : l10n.tooltipWatchlistAdd,
            visualDensity:
                dense ? VisualDensity.compact : VisualDensity.standard,
          ),
        ],
      ),
    );
  }
}
