import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/parser/response_parser.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';

final class MarketsResponseParser
    implements ResponseParser<List<dynamic>, List<CryptoAssetDto>> {
  const MarketsResponseParser();

  @override
  List<CryptoAssetDto> parse(List<dynamic> input) {
    return input
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ResponseParsingException();
          }
          return CryptoAssetDto.fromJson(item);
        })
        .toList(growable: false);
  }
}
