extension NullableStringX on String? {
  /// Returns `null` if the string is `null` or empty, otherwise returns itself.
  String? get nonEmpty => this != null && this!.isNotEmpty ? this : null;

  /// Strips HTML tags, collapses whitespace and truncates to [maxLength].
  /// Returns `null` if the source is `null` or empty.
  String? cleanHtml({int maxLength = 800}) {
    final src = nonEmpty;
    if (src == null) return null;
    var plain = src
        .replaceAll(RegExp('<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.length > maxLength) {
      plain = '${plain.substring(0, maxLength)}…';
    }
    return plain;
  }
}
