import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';

class CryptoCoinDetailModel {
  const CryptoCoinDetailModel({
    required this.id,
    required this.symbol,
    required this.name,
    this.description,
    this.currentPriceUsd,
    this.priceChangePercent24h,
    this.imageUrl,
  });

  factory CryptoCoinDetailModel.fromJson(Map<String, dynamic> json) {
    final descMap = json['description'];
    String? plain;
    if (descMap is Map && descMap['en'] is String) {
      final raw = descMap['en'] as String;
      plain = raw
          .replaceAll(RegExp('<[^>]*>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (plain.length > 800) {
        plain = '${plain.substring(0, 800)}…';
      }
    }

    final marketData = json['market_data'];
    double? price;
    double? ch24;
    if (marketData is Map<String, dynamic>) {
      final cp = marketData['current_price'];
      if (cp is Map && cp['usd'] is num) {
        price = (cp['usd'] as num).toDouble();
      }
      ch24 = (marketData['price_change_percentage_24h'] as num?)?.toDouble();
    }

    final image = json['image'];
    String? imgUrl;
    if (image is Map && image['large'] is String) {
      imgUrl = image['large'] as String;
    }

    return CryptoCoinDetailModel(
      id: json['id'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      name: json['name'] as String? ?? '',
      description: plain,
      currentPriceUsd: price,
      priceChangePercent24h: ch24,
      imageUrl: imgUrl,
    );
  }

  final String id;
  final String symbol;
  final String name;
  final String? description;
  final double? currentPriceUsd;
  final double? priceChangePercent24h;
  final String? imageUrl;

  CryptoCoinDetail toEntity() {
    return CryptoCoinDetail(
      id: id,
      symbol: symbol,
      name: name,
      description: description,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      imageUrl: imageUrl,
    );
  }
}
