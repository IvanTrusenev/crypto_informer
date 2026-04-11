import 'package:crypto_informer/core/network/parser/response_parser.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';

final class CoinDetailResponseParser
    implements ResponseParser<Map<String, dynamic>, CryptoCoinDetailDto> {
  const CoinDetailResponseParser();

  @override
  CryptoCoinDetailDto parse(Map<String, dynamic> input) {
    return CryptoCoinDetailDto.fromJson(input);
  }
}
