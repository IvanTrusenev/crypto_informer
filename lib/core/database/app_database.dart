import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = p.join(dir.path, 'crypto_informer.db');
  return openDatabase(
    filePath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE market_assets_cache (
          vs_currency TEXT NOT NULL PRIMARY KEY,
          updated_at INTEGER NOT NULL,
          payload TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE coin_detail_cache (
          coin_id TEXT NOT NULL PRIMARY KEY,
          updated_at INTEGER NOT NULL,
          payload TEXT NOT NULL
        )
      ''');
    },
  );
}
