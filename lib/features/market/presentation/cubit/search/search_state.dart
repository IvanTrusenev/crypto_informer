import 'package:crypto_informer/features/market/presentation/cubit/search/search_status_enum.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.status = SearchStatusEnum.idle,
    this.ids = const [],
  });

  final String query;
  final SearchStatusEnum status;
  final List<String> ids;

  bool get hasActiveQuery => query.isNotEmpty;

  SearchState copyWith({
    String? query,
    SearchStatusEnum? status,
    List<String>? ids,
  }) {
    return SearchState(
      query: query ?? this.query,
      status: status ?? this.status,
      ids: ids ?? this.ids,
    );
  }
}
