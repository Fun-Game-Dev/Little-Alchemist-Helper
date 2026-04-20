import 'dart:convert';

import 'package:flutter/foundation.dart';

/// [visibleDays] calendar days starting [shopStart] (inclusive); window is
/// `[shopStart, shopStart + visibleDays)`.
bool shopPackIsInWindow({
  required DateTime shopStart,
  required int visibleDays,
  required DateTime now,
}) {
  final DateTime start = DateTime(shopStart.year, shopStart.month, shopStart.day);
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime endExclusive = start.add(Duration(days: visibleDays));
  return !today.isBefore(start) && today.isBefore(endExclusive);
}

String shopPackImageAssetPath(String imageFile) {
  return 'assets/images/shop_packs/$imageFile';
}

@immutable
class ShopPackEntry {
  const ShopPackEntry({
    required this.id,
    required this.displayName,
    required this.shopStart,
    required this.section,
    required this.occasion,
    required this.gcc,
    required this.imageFile,
  });

  final String id;
  final String displayName;
  final DateTime shopStart;
  final String section;
  /// From `:occ:` in [tool/pack_schedule_source.txt] (Onyx line in UI).
  final String occasion;
  /// From `:gcc:` in [tool/pack_schedule_source.txt] (Gold line in UI).
  final String gcc;
  final String imageFile;

  static ShopPackEntry fromJson(Map<String, dynamic> json) {
    final String? id = json['id'] as String?;
    final String? name = json['displayName'] as String?;
    final String? start = json['shopStart'] as String?;
    if (id == null || name == null || start == null) {
      throw FormatException('Invalid shop pack: $json');
    }
    final DateTime? parsedTry = DateTime.tryParse(start);
    if (parsedTry == null) {
      throw FormatException('Bad shopStart: $start');
    }
    final DateTime parsed = parsedTry;
    return ShopPackEntry(
      id: id,
      displayName: name,
      shopStart: DateTime(parsed.year, parsed.month, parsed.day),
      section: (json['section'] as String?) ?? '',
      occasion: (json['occasion'] as String?) ?? '',
      gcc: (json['gcc'] as String?) ?? '',
      imageFile: (json['imageFile'] as String?) ?? '$id.png',
    );
  }
}

@immutable
class ShopPackBundle {
  const ShopPackBundle({
    required this.shopVisibleDays,
    required this.packs,
    required this.cardNamesByPackId,
  });

  final int shopVisibleDays;
  final List<ShopPackEntry> packs;
  final Map<String, List<String>> cardNamesByPackId;

  static ShopPackBundle parse(String shopPacksJson, String contentsJson) {
    final Object? packsRootRaw = _decode(shopPacksJson);
    if (packsRootRaw is! Map) {
      throw const FormatException('shop_packs.json: root must be object');
    }
    final Map<String, dynamic> packsRoot =
        Map<String, dynamic>.from(packsRootRaw);
    final int days = (packsRoot['shopVisibleDays'] as num?)?.toInt() ?? 4;
    final Object? packsRaw = packsRoot['packs'];
    if (packsRaw is! List<dynamic>) {
      throw const FormatException('shop_packs.json: packs must be array');
    }
    final List<ShopPackEntry> packs = <ShopPackEntry>[];
    for (final Object? e in packsRaw) {
      if (e is Map) {
        packs.add(
          ShopPackEntry.fromJson(Map<String, dynamic>.from(e)),
        );
      }
    }
    final Object? contentsRootRaw = _decode(contentsJson);
    final Map<String, List<String>> byId = <String, List<String>>{};
    if (contentsRootRaw is Map) {
      final Map<String, dynamic> contentsRoot =
          Map<String, dynamic>.from(contentsRootRaw);
      final Object? byPackRaw = contentsRoot['byPackId'];
      if (byPackRaw is Map) {
        Map<String, dynamic>.from(byPackRaw).forEach((String key, Object? value) {
          if (value is Map) {
            final Map<String, dynamic> entry = Map<String, dynamic>.from(value);
            final Object? names = entry['cardDisplayNames'];
            if (names is List<dynamic>) {
              byId[key] = names
                  .whereType<String>()
                  .map((String s) => s.trim())
                  .where((String s) => s.isNotEmpty)
                  .toList(growable: false);
            }
          }
        });
      }
    }
    return ShopPackBundle(
      shopVisibleDays: days,
      packs: List<ShopPackEntry>.unmodifiable(packs),
      cardNamesByPackId: Map<String, List<String>>.unmodifiable(byId),
    );
  }

  /// Уникальные `:occ:` из [assets/data/pack_schedule_occasions.json], собранного
  /// [tool/build_shop_packs_json.dart] из [tool/pack_schedule_source.txt].
  /// Резервный allowlist для синтетического материала Onyx, если пуст парсинг
  /// `assets/data/onyx_wiki_display_names.json`.
  static Set<String> occasionAllowlistFromPackScheduleOccasionsJson(
    String raw,
  ) {
    final Object? rootRaw = _decode(raw);
    if (rootRaw is! Map) {
      return <String>{};
    }
    final Object? listRaw = rootRaw['occasions'];
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
  }

  /// Уникальные строки [ShopPackEntry.occasion] из `assets/data/shop_packs.json`.
  /// Резервный allowlist имён (если пуст `onyx_wiki_display_names.json` и расписание).
  ///
  /// Предпочтительно [occasionAllowlistFromPackScheduleOccasionsJson] перед этим методом.
  static Set<String> uniqueOccasionDisplayNamesFromShopPacksJson(
    String shopPacksJson,
  ) {
    final Object? rootRaw = _decode(shopPacksJson);
    if (rootRaw is! Map) {
      return <String>{};
    }
    final Object? packsRaw = rootRaw['packs'];
    if (packsRaw is! List<dynamic>) {
      return <String>{};
    }
    final Set<String> out = <String>{};
    for (final Object? e in packsRaw) {
      if (e is Map) {
        final Object? o = e['occasion'];
        if (o is String) {
          final String t = o.trim();
          if (t.isNotEmpty) {
            out.add(t);
          }
        }
      }
    }
    return out;
  }

  static Object? _decode(String raw) {
    return _stripJsonComments(raw);
  }

  /// Minimal `//` line comments strip for optional hand-edited JSON.
  static Object? _stripJsonComments(String raw) {
    final StringBuffer out = StringBuffer();
    for (final String line in raw.split('\n')) {
      final int c = line.indexOf('//');
      if (c >= 0) {
        out.writeln(line.substring(0, c));
      } else {
        out.writeln(line);
      }
    }
    return jsonDecode(out.toString());
  }
}
