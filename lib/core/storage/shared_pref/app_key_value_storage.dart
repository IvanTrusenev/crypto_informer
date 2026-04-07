/// Абстракция над key-value хранилищем приложения.
abstract class AppKeyValueStorage {
  String? getString(String key);
  Future<bool> setString(String key, String value);

  List<String>? getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);

  bool? getBool(String key);

  Future<bool> remove(String key);
}
