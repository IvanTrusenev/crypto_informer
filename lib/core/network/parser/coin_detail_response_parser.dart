import 'package:crypto_informer/core/network/parser/response_parser.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_dto.dart';

final class CoinDetailResponseParser
    implements ResponseParser<Map<String, dynamic>, CoinDetailDto> {
  const CoinDetailResponseParser();

  @override
  CoinDetailDto parse(Map<String, dynamic> input) {
    return CoinDetailDto.fromJson(input);
  }
}
