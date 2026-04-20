import 'dart:convert';

/// Allowlist имён [AlchemyCard.displayName] для синтетического материала Onyx.
/// Полный список страниц вики «… (Onyx)» — категория
/// [sourceWikiUrl] в [assets/data/onyx_wiki_display_names.json].
class OnyxWikiAllowlist {
  OnyxWikiAllowlist._();

  /// Парсит bundled JSON; при ошибке формата или пустом списке возвращает пустое множество.
  static Set<String> displayNameSetFromBundledJson(String raw) {
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String>{};
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
      final Object? listRaw = map['displayNames'];
      if (listRaw is! List<dynamic>) {
        return <String>{};
      }
      final Set<String> out = <String>{};
      for (final Object? e in listRaw) {
        if (e is String) {
          final String t = e.trim();
          if (t.isNotEmpty) {
            out.add(t);
          }
        }
      }
      return out;
    } on Object catch (_) {
      return <String>{};
    }
  }
}
