import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

/// Поиск идентификаторов монет по строке запроса.
class SearchCoinIdsUseCase {
  const SearchCoinIdsUseCase(this._repository);

  final CryptoRepository _repository;

  Future<List<String>> call(String query) {
    return _repository.searchCoinIds(query.trim());
  }
}
