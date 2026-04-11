import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/parser/response_parser.dart';

final class SearchIdsResponseParser
    implements ResponseParser<Map<String, dynamic>, List<String>> {
  const SearchIdsResponseParser();

  @override
  List<String> parse(Map<String, dynamic> input) {
    final coins = input['coins'];
    if (coins is! List) {
      throw const ResponseParsingException();
    }

    return coins
        .map((coin) {
          if (coin is! Map<String, dynamic>) {
            throw const ResponseParsingException();
          }

          final id = coin['id'];
          if (id is! String) {
            throw const ResponseParsingException();
          }

          return id;
        })
        .toList(growable: false);
  }
}
