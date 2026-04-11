import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/parser/response_parser.dart';
import 'package:crypto_informer/features/market/data/models/coin_dto.dart';

final class MarketsResponseParser
    implements ResponseParser<List<dynamic>, List<CoinDto>> {
  const MarketsResponseParser();

  @override
  List<CoinDto> parse(List<dynamic> input) {
    return input
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ResponseParsingException();
          }
          return CoinDto.fromJson(item);
        })
        .toList(growable: false);
  }
}
