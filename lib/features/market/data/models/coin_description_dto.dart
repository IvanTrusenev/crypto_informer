/// Локализованные описания монеты (CoinGecko `/coins/{id}`, поле `description`).
///
/// Ключи — коды языка (`en`, `de`, …), значения — строки (часто с HTML).
class CoinDescriptionDto {
  const CoinDescriptionDto({required this.byLocale});

  /// Пары `locale → текст` из JSON.
  final Map<String, String> byLocale;

  /// Описание на английском (основной язык для UI).
  String? get en => byLocale['en'];

  static CoinDescriptionDto? fromJson(Object? json) {
    if (json == null || json is! Map) return null;
    final map = <String, String>{};
    for (final e in json.entries) {
      final v = e.value;
      if (v is String) {
        map[e.key.toString()] = v;
      }
    }
    return CoinDescriptionDto(byLocale: map);
  }
}
