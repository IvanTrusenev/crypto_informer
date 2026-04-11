import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/parser/response_parser.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';

final class MarketChartResponseParser
    implements ResponseParser<Map<String, dynamic>, List<PriceChartPointDto>> {
  const MarketChartResponseParser();

  @override
  List<PriceChartPointDto> parse(Map<String, dynamic> input) {
    final raw = input['prices'];
    if (raw is! List) {
      throw const ResponseParsingException();
    }

    return raw
        .map((pair) {
          if (pair is! List<dynamic> || pair.length < 2) {
            throw const ResponseParsingException();
          }

          final timestamp = pair[0];
          final price = pair[1];
          if (timestamp is! num || price is! num) {
            throw const ResponseParsingException();
          }

          return PriceChartPointDto(
            timestampMs: timestamp.toInt(),
            priceUsd: price.toDouble(),
          );
        })
        .toList(growable: false);
  }
}
