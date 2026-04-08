import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/widgets/centered_circular_progress.dart';
import 'package:crypto_informer/core/widgets/centered_error_message.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_detail/export.dart';
import 'package:crypto_informer/features/market/presentation/pages/coin_detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Содержимое [Scaffold.body] экрана деталей монеты.
class CoinDetailBody extends StatelessWidget {
  const CoinDetailBody({
    required this.coinId,
    super.key,
  });

  final String coinId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CoinDetailCubit, CoinDetailState>(
      builder: (context, state) => switch (state) {
        CoinDetailInitial() || CoinDetailLoading() =>
          const CenteredCircularProgress(),
        CoinDetailLoaded(:final detail) => CoinDetailContent(
          detail: detail,
          coinId: coinId,
        ),
        CoinDetailError(:final error) => CenteredErrorMessage(
          message: localizedErrorMessage(l10n, error),
        ),
      },
    );
  }
}
