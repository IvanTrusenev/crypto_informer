// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FroomGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FroomAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(path, _migrations, _callback);
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CoinCacheDao? _coinCacheDaoInstance;

  CoinDetailCacheDao? _coinDetailCacheDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
          database,
          startVersion,
          endVersion,
          migrations,
        );

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `coin_cache` (`cache_key` TEXT NOT NULL, `id` TEXT NOT NULL, `vs_currency` TEXT NOT NULL, `sort_order` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `symbol` TEXT NOT NULL, `name` TEXT NOT NULL, `current_price_usd` REAL NOT NULL, `price_change_percent_24h` REAL NOT NULL, `market_cap_usd` REAL, `image_url` TEXT, PRIMARY KEY (`cache_key`))',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `coin_detail_cache` (`id` TEXT NOT NULL, `updated_at` INTEGER NOT NULL, `symbol` TEXT NOT NULL, `name` TEXT NOT NULL, `description` TEXT, `current_price_usd` REAL, `price_change_percent_24h` REAL, `image_url` TEXT, PRIMARY KEY (`id`))',
        );

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CoinCacheDao get coinCacheDao {
    return _coinCacheDaoInstance ??= _$CoinCacheDao(database, changeListener);
  }

  @override
  CoinDetailCacheDao get coinDetailCacheDao {
    return _coinDetailCacheDaoInstance ??= _$CoinDetailCacheDao(
      database,
      changeListener,
    );
  }
}

class _$CoinCacheDao extends CoinCacheDao {
  _$CoinCacheDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _coinCacheRecordInsertionAdapter = InsertionAdapter(
        database,
        'coin_cache',
        (CoinCacheRecord item) => <String, Object?>{
          'cache_key': item.cacheKey,
          'id': item.id,
          'vs_currency': item.vsCurrency,
          'sort_order': item.sortOrder,
          'updated_at': item.updatedAt,
          'symbol': item.symbol,
          'name': item.name,
          'current_price_usd': item.currentPriceUsd,
          'price_change_percent_24h': item.priceChangePercent24h,
          'market_cap_usd': item.marketCapUsd,
          'image_url': item.imageUrl,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CoinCacheRecord> _coinCacheRecordInsertionAdapter;

  @override
  Future<List<CoinCacheRecord>> findByVsCurrency(String vsCurrency) async {
    return _queryAdapter.queryList(
      'SELECT *     FROM coin_cache     WHERE vs_currency = ?1     ORDER BY sort_order ASC',
      mapper: (Map<String, Object?> row) => CoinCacheRecord(
        cacheKey: row['cache_key'] as String,
        id: row['id'] as String,
        vsCurrency: row['vs_currency'] as String,
        sortOrder: row['sort_order'] as int,
        updatedAt: row['updated_at'] as int,
        symbol: row['symbol'] as String,
        name: row['name'] as String,
        currentPriceUsd: row['current_price_usd'] as double,
        priceChangePercent24h: row['price_change_percent_24h'] as double,
        marketCapUsd: row['market_cap_usd'] as double?,
        imageUrl: row['image_url'] as String?,
      ),
      arguments: [vsCurrency],
    );
  }

  @override
  Future<void> deleteByVsCurrency(String vsCurrency) async {
    await _queryAdapter.queryNoReturn(
      'DELETE FROM coin_cache WHERE vs_currency = ?1',
      arguments: [vsCurrency],
    );
  }

  @override
  Future<void> insert(List<CoinCacheRecord> records) async {
    await _coinCacheRecordInsertionAdapter.insertList(
      records,
      OnConflictStrategy.replace,
    );
  }

  @override
  Future<void> replaceByVsCurrency(
    String vsCurrency,
    List<CoinCacheRecord> records,
  ) async {
    if (database is sqflite.Transaction) {
      await super.replaceByVsCurrency(vsCurrency, records);
    } else {
      await (database as sqflite.Database).transaction<void>((
        transaction,
      ) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.coinCacheDao.replaceByVsCurrency(
          vsCurrency,
          records,
        );
      });
    }
  }
}

class _$CoinDetailCacheDao extends CoinDetailCacheDao {
  _$CoinDetailCacheDao(this.database, this.changeListener)
    : _queryAdapter = QueryAdapter(database),
      _coinDetailCacheRecordInsertionAdapter = InsertionAdapter(
        database,
        'coin_detail_cache',
        (CoinDetailCacheRecord item) => <String, Object?>{
          'id': item.id,
          'updated_at': item.updatedAt,
          'symbol': item.symbol,
          'name': item.name,
          'description': item.description,
          'current_price_usd': item.currentPriceUsd,
          'price_change_percent_24h': item.priceChangePercent24h,
          'image_url': item.imageUrl,
        },
      );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CoinDetailCacheRecord>
  _coinDetailCacheRecordInsertionAdapter;

  @override
  Future<int?> count() async {
    return _queryAdapter.query(
      'SELECT COUNT(*) FROM coin_detail_cache',
      mapper: (Map<String, Object?> row) => row.values.first as int,
    );
  }

  @override
  Future<CoinDetailCacheRecord?> findById(String id) async {
    return _queryAdapter.query(
      'SELECT * FROM coin_detail_cache WHERE id = ?1 LIMIT 1',
      mapper: (Map<String, Object?> row) => CoinDetailCacheRecord(
        id: row['id'] as String,
        updatedAt: row['updated_at'] as int,
        symbol: row['symbol'] as String,
        name: row['name'] as String,
        description: row['description'] as String?,
        currentPriceUsd: row['current_price_usd'] as double?,
        priceChangePercent24h: row['price_change_percent_24h'] as double?,
        imageUrl: row['image_url'] as String?,
      ),
      arguments: [id],
    );
  }

  @override
  Future<void> upsert(CoinDetailCacheRecord record) async {
    await _coinDetailCacheRecordInsertionAdapter.insert(
      record,
      OnConflictStrategy.replace,
    );
  }
}
