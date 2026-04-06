import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Приложение строит нижнюю навигацию', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketAssetsProvider.overrideWith((ref) async => <CryptoAsset>[]),
        ],
        child: const CryptoInformerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Market'), findsWidgets);
  });
}
