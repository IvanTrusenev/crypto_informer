import 'dart:async';

import 'package:crypto_informer/core/di/service_locator.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_detail/export.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_price_chart/export.dart';
import 'package:crypto_informer/features/market/presentation/pages/coin_detail_app_bar.dart';
import 'package:crypto_informer/features/market/presentation/pages/coin_detail_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({required this.coinId, super.key});

  final String coinId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = CoinDetailCubit(sl<GetCoinDetailUseCase>());
            unawaited(cubit.loadDetail(coinId));
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = CoinPriceChartCubit(sl());
            unawaited(cubit.loadChart(coinId));
            return cubit;
          },
        ),
      ],
      child: Scaffold(
        appBar: CoinDetailAppBar(coinId: coinId),
        body: CoinDetailBody(coinId: coinId),
      ),
    );
  }
}
