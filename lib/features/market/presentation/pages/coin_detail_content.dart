import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/presentation/widgets/coin_price_chart_section.dart';
import 'package:flutter/material.dart';

/// Контент списка при успешной загрузке деталей монеты.
class CoinDetailContent extends StatelessWidget {
  const CoinDetailContent({
    required this.detail,
    required this.coinId,
    super.key,
  });

  final CryptoCoinDetailEntity detail;
  final String coinId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceFormat = context.usdCurrencyFormat;
    final change24h = detail.priceChangePercent24h;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (detail.imageUrl != null)
          Center(
            child: Hero(
              tag: 'coin_avatar_${detail.id}',
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
        if (change24h != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.coinChange24h(
              '${change24h >= 0 ? '+' : ''}'
              '${change24h.toStringAsFixed(2)}',
            ),
            textAlign: TextAlign.center,
            style: context.theme.textTheme.labelLarge?.copyWith(
              color: change24h >= 0
                  ? context.financeColors.pricePositive
                  : context.financeColors.priceNegative,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 24),
        CoinPriceChartSection(coinId: coinId),
        if (detail.description?.isNotEmpty ?? false) ...[
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
  }
}
