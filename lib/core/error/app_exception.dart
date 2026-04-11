part 'cache/cache_exception.dart';
part 'cache/cache_read_exception.dart';
part 'cache/cache_write_exception.dart';
part 'market/coin_not_found_exception.dart';
part 'market/market_exception.dart';
part 'network/empty_response_exception.dart';
part 'network/not_found_exception.dart';
part 'network/network_exception.dart';
part 'network/response_parsing_exception.dart';
part 'network/network_timeout_exception.dart';
part 'network/too_many_requests_exception.dart';
part 'network/unauthorized_exception.dart';
part 'network/network_unavailable_exception.dart';
part 'network/server_error_exception.dart';
part 'validation/validation_exception.dart';

/// Ошибка уровня приложения без привязки к языку UI.
sealed class AppException implements Exception {
  const AppException();
}
