import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/export.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/export.dart';
import 'package:crypto_informer/features/market/presentation/pages/market_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketTitle)),
      body: MarketBody(
        scrollController: _scrollController,
        searchController: _searchController,
        onSearchChanged: _scheduleSearchUpdate,
        onClearSearch: _clearSearch,
        onRetry: () =>
            context.read<MarketBloc>().add(const MarketLoadRequested()),
      ),
    );
  }

  void _scheduleSearchUpdate(String text) {
    if (!mounted) return;
    context.read<SearchBloc>().add(SearchQueryChanged(text));
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<MarketBloc>().add(const MarketLoadMoreRequested());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }
}
