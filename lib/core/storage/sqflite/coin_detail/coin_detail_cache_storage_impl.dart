import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/storage/sqflite/coin_detail/coin_detail_cache_dao.dart';
import 'package:crypto_informer/core/storage/sqflite/coin_detail/mapper/coin_detail_cache_model_mapper.dart';
import 'package:crypto_informer/core/storage/sqflite/coin_detail/mapper/coin_detail_cache_record_mapper.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';
import 'package:crypto_informer/features/market/data/storage/coin_detail_cache_storage.dart';

class CoinDetailCacheStorageImpl implements CoinDetailCacheStorage {
  CoinDetailCacheStorageImpl(this._dao);

  final CoinDetailCacheDao _dao;

  @override
  Future<int> count() async {
    try {
      return await _dao.count() ?? 0;
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const CacheReadException();
    }
  }

  @override
  Future<CoinDetailCacheModel?> readById(String id) async {
    try {
      final record = await _dao.findById(id);
      return record?.toCacheModel();
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const CacheReadException();
    }
  }

  @override
  Future<void> save(CoinDetailCacheModel detail) async {
    try {
      await _dao.upsert(
        detail.toCacheRecord(
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const CacheWriteException();
    }
  }
}
