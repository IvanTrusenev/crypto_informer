import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/presentation/widgets/crypto_asset_list_tile.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const asset = CryptoAssetEntity(
    id: 'bitcoin',
    symbol: 'BTC',
    name: 'Bitcoin',
    currentPriceUsd: 65000,
    priceChangePercent24h: 2.5,
  );

  Widget buildWidget({
    bool inWatchlist = false,
    VoidCallback? onTap,
    VoidCallback? onToggleStar,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return CryptoAssetListTile(
              asset: asset,
              priceText: r'$65,000.00',
              inWatchlist: inWatchlist,
              l10n: l10n,
              onTap: onTap ?? () {},
              onToggleStar: onToggleStar ?? () {},
            );
          },
        ),
      ),
    );
  }

  testWidgets('renders name and price', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text(r'$65,000.00'), findsOneWidget);
  });

  testWidgets('shows star icon', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('shows filled star when in watchlist', (tester) async {
    await tester.pumpWidget(buildWidget(inWatchlist: true));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
