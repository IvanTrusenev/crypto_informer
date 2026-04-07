import 'package:crypto_informer/features/watchlist/presentation/widgets/animated_watchlist_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tap calls onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedWatchlistIconButton(
            isInWatchlist: false,
            tooltip: 'Add',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton));
    expect(tapped, isTrue);
  });

  testWidgets('displays star_border when not in watchlist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedWatchlistIconButton(
            isInWatchlist: false,
            tooltip: 'Add',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('displays star when in watchlist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedWatchlistIconButton(
            isInWatchlist: true,
            tooltip: 'Remove',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
