import 'dart:convert';

import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class CryptoLocalDataSource {
  Future<List<CryptoAsset>?> readMarketAssets({String vsCurrency});

  Future<void> replaceMarketAssets(
    List<CryptoAsset> items, {
    String vsCurrency,
  });

  Future<CryptoCoinDetail?> readCoinDetail(String id);

  Future<void> saveCoinDetail(CryptoCoinDetail detail);
}

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  CryptoLocalDataSourceImpl(this._db);

  final Database _db;

  static const _marketTable = 'market_assets_cache';
  static const _coinTable = 'coin_detail_cache';

  @override
  Future<List<CryptoAsset>?> readMarketAssets({
    String vsCurrency = 'usd',
  }) async {
    final rows = await _db.query(
      _marketTable,
      where: 'vs_currency = ?',
      whereArgs: [vsCurrency],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['payload'] as String?;
    if (raw == null || raw.isEmpty) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _cryptoAssetFromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> replaceMarketAssets(
    List<CryptoAsset> items, {
    String vsCurrency = 'usd',
  }) async {
    final payload = jsonEncode(items.map(_cryptoAssetToJson).toList());
    await _db.insert(
      _marketTable,
      {
        'vs_currency': vsCurrency,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'payload': payload,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<CryptoCoinDetail?> readCoinDetail(String id) async {
    final rows = await _db.query(
      _coinTable,
      where: 'coin_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['payload'] as String?;
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return _cryptoCoinDetailFromJson(map);
  }

  @override
  Future<void> saveCoinDetail(CryptoCoinDetail detail) async {
    final payload = jsonEncode(_cryptoCoinDetailToJson(detail));
    await _db.insert(
      _coinTable,
      {
        'coin_id': detail.id,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'payload': payload,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Map<String, dynamic> _cryptoAssetToJson(CryptoAsset a) {
  return {
    'id': a.id,
    'symbol': a.symbol,
    'name': a.name,
    'current_price': a.currentPriceUsd,
    'price_change_percentage_24h': a.priceChangePercent24h,
    'image': a.imageUrl,
  };
}

CryptoAsset _cryptoAssetFromJson(Map<String, dynamic> m) {
  final image = m['image'];
  return CryptoAsset(
    id: m['id'] as String? ?? '',
    symbol: (m['symbol'] as String? ?? '').toUpperCase(),
    name: m['name'] as String? ?? '',
    currentPriceUsd: (m['current_price'] as num?)?.toDouble() ?? 0,
    priceChangePercent24h:
        (m['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
    imageUrl: image is String && image.isNotEmpty ? image : null,
  );
}

Map<String, dynamic> _cryptoCoinDetailToJson(CryptoCoinDetail d) {
  return {
    'id': d.id,
    'symbol': d.symbol,
    'name': d.name,
    'description': d.description,
    'current_price_usd': d.currentPriceUsd,
    'price_change_percentage_24h': d.priceChangePercent24h,
    'image': d.imageUrl,
  };
}

CryptoCoinDetail _cryptoCoinDetailFromJson(Map<String, dynamic> m) {
  final image = m['image'];
  return CryptoCoinDetail(
    id: m['id'] as String? ?? '',
    symbol: (m['symbol'] as String? ?? '').toUpperCase(),
    name: m['name'] as String? ?? '',
    description: m['description'] as String?,
    currentPriceUsd: (m['current_price_usd'] as num?)?.toDouble(),
    priceChangePercent24h: (m['price_change_percentage_24h'] as num?)
        ?.toDouble(),
    imageUrl: image is String && image.isNotEmpty ? image : null,
  );
}
