import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppKeyValueStorageImpl implements AppKeyValueStorage {
  AppKeyValueStorageImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);
}
