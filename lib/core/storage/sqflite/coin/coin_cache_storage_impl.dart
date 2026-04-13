import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/storage/sqflite/coin/coin_cache_dao.dart';
import 'package:crypto_informer/core/storage/sqflite/coin/mapper/coin_cache_model_mapper.dart';
import 'package:crypto_informer/core/storage/sqflite/coin/mapper/coin_cache_record_mapper.dart';
import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';
import 'package:crypto_informer/features/market/data/storage/coin_cache_storage.dart';

class CoinCacheStorageImpl implements CoinCacheStorage {
  CoinCacheStorageImpl(this._dao);

  final CoinCacheDao _dao;

  @override
  Future<List<CoinCacheModel>?> readByVsCurrency(String vsCurrency) async {
    try {
      final records = await _dao.findByVsCurrency(vsCurrency);
      if (records.isEmpty) return null;
      return records
          .map((record) => record.toCacheModel())
          .toList(growable: false);
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const CacheReadException();
    }
  }

  @override
  Future<void> replaceByVsCurrency(
    String vsCurrency,
    List<CoinCacheModel> items,
  ) async {
    try {
      final updatedAt = DateTime.now().millisecondsSinceEpoch;
      final records = [
        for (var index = 0; index < items.length; index++)
          items[index].toCacheRecord(
            vsCurrency: vsCurrency,
            sortOrder: index,
            updatedAt: updatedAt,
          ),
      ];
      await _dao.replaceByVsCurrency(vsCurrency, records);
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const CacheWriteException();
    }
  }
}
