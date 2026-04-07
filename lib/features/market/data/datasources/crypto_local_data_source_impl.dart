import 'dart:convert';

import 'package:crypto_informer/core/storage/sql/app_database.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_asset_dao_from_entity_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_asset_dao_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_coin_detail_dao_from_entity_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_coin_detail_dao_mapper.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:sqflite/sqflite.dart';

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  CryptoLocalDataSourceImpl(this._appDb);

  final AppDatabase _appDb;
  Database get _db => _appDb.database;

  static const _marketTable = 'market_assets_cache';
  static const _coinTable = 'coin_detail_cache';

  @override
  Future<List<CryptoAssetEntity>?> readMarketAssets({
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
        .map(
          (e) =>
              CryptoAssetDao.fromJson(e as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<void> replaceMarketAssets(
    List<CryptoAssetEntity> items, {
    String vsCurrency = 'usd',
  }) async {
    final payload = jsonEncode(
      items.map((a) => a.toDao().toJson()).toList(),
    );
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
  Future<CryptoCoinDetailEntity?> readCoinDetail(String id) async {
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
    return CryptoCoinDetailDao.fromJson(map).toEntity();
  }

  @override
  Future<void> saveCoinDetail(CryptoCoinDetailEntity detail) async {
    final payload = jsonEncode(detail.toDao().toJson());
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
