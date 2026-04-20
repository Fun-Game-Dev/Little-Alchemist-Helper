import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'shop_pack_models.dart';

/// Bundled JSON from [tool/build_special_packs_json.dart] (wiki Special Packs list).
@immutable
class SpecialPackCatalog {
  const SpecialPackCatalog({
    required this.wikiListUrl,
    required this.packs,
  });

  final String wikiListUrl;
  final List<SpecialPackEntry> packs;

  static SpecialPackCatalog parse(String jsonRaw) {
    final Object? rootRaw = jsonDecode(jsonRaw);
    if (rootRaw is! Map) {
      throw const FormatException('special_packs.json: root must be object');
    }
    final Map<String, dynamic> root = Map<String, dynamic>.from(rootRaw);
    final String wikiListUrl =
        (root['wikiListUrl'] as String?) ??
        'https://lil-alchemist.fandom.com/wiki/Special_Packs';
    final Object? packsRaw = root['packs'];
    if (packsRaw is! List<dynamic>) {
      throw const FormatException('special_packs.json: packs must be array');
    }
    final List<SpecialPackEntry> packs = <SpecialPackEntry>[];
    for (final Object? e in packsRaw) {
      if (e is Map) {
        packs.add(SpecialPackEntry.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return SpecialPackCatalog(
      wikiListUrl: wikiListUrl,
      packs: List<SpecialPackEntry>.unmodifiable(packs),
    );
  }
}

@immutable
class SpecialPackEntry {
  const SpecialPackEntry({
    required this.wikiSlug,
    required this.displayName,
    required this.section,
    required this.selectorFile,
    required this.wikiImageUrl,
  });

  final String wikiSlug;
  final String displayName;
  final String section;
  final String selectorFile;
  final String wikiImageUrl;

  static SpecialPackEntry fromJson(Map<String, dynamic> json) {
    final String? slug = json['wikiSlug'] as String?;
    final String? name = json['displayName'] as String?;
    if (slug == null || slug.isEmpty || name == null || name.isEmpty) {
      throw FormatException('Invalid special pack: $json');
    }
    return SpecialPackEntry(
      wikiSlug: slug,
      displayName: name,
      section: (json['section'] as String?) ?? '',
      selectorFile: (json['selectorFile'] as String?) ?? '$slug.png',
      wikiImageUrl: (json['wikiImageUrl'] as String?) ?? '',
    );
  }

  /// `https://lil-alchemist.fandom.com/wiki/Special_Packs/Accursed`
  String wikiPageUrl() {
    final String enc = wikiSlug
        .split('/')
        .map((String s) => Uri.encodeComponent(s))
        .join('/');
    return 'https://lil-alchemist.fandom.com/wiki/Special_Packs/$enc';
  }

  /// Same calendar rules as [shopPackIsInWindow], keyed by rotating schedule [ShopPackEntry.displayName].
  bool matchesSchedulePackName(String scheduleDisplayName) {
    final String a = scheduleDisplayName.trim().toLowerCase();
    final String slugTitle = wikiSlug.replaceAll('_', ' ').trim().toLowerCase();
    if (a == slugTitle) {
      return true;
    }
    String dn = displayName.trim().toLowerCase();
    if (dn.endsWith(' pack')) {
      dn = dn.substring(0, dn.length - ' pack'.length).trim();
    }
    return a == dn;
  }
}

extension SpecialPackScheduleLookup on SpecialPackEntry {
  /// Earliest [ShopPackEntry] in [bundle] whose [ShopPackEntry.displayName] matches this pack.
  ShopPackEntry? primaryScheduleRow(ShopPackBundle bundle) {
    final List<ShopPackEntry> matches = bundle.packs
        .where((ShopPackEntry p) => matchesSchedulePackName(p.displayName))
        .toList();
    if (matches.isEmpty) {
      return null;
    }
    matches.sort(
      (ShopPackEntry a, ShopPackEntry b) => a.shopStart.compareTo(b.shopStart),
    );
    return matches.first;
  }
}
