import 'package:sqflite/sqflite.dart';

/// Абстракция над SQL-базой данных приложения.
abstract class AppDatabase {
  /// Экземпляр [Database] для выполнения запросов.
  Database get database;

  /// Закрытие соединения с БД.
  Future<void> close();
}
