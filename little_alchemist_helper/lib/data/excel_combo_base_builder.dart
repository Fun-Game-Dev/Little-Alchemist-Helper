import 'dart:convert';

/// Builds root catalog object (same shape as [AlchemyCardData.json]) from TSV
/// [assets/data_from_exel.txt]: fusion pairs and base result A/D by rows.
class ExcelComboBaseBuilder {
  const ExcelComboBaseBuilder._();

  /// [tsv] is raw file content with a header and tab-separated columns.
  static Map<String, Object?> buildRootMap(String tsv) {
    String body = tsv;
    if (body.startsWith('\uFEFF')) {
      body = body.substring(1);
    }
    final List<String> lines = body.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) {
      return <String, Object?>{};
    }
    final List<String> header = _splitTsvLine(lines.first);
    final Map<String, int> col = <String, int>{};
    for (int i = 0; i < header.length; i++) {
      final String name = header[i].trim();
      if (name.isNotEmpty) {
        col[name] = i;
      }
    }
    final int? iA = col['CC_A'];
    final int? iB = col['CC_B'];
    final int? iRes = col['Res'];
    final int? iResRare = col['Res_Rare'];
    final int? iBa0 = col['BA_0O'];
    final int? iBd0 = col['BD_0O'];
    if (iA == null || iB == null || iRes == null) {
      throw const FormatException(
        'В data_from_exel.txt нет колонок CC_A, CC_B или Res',
      );
    }
    final Map<String, Object?> root = <String, Object?>{};
    for (int li = 1; li < lines.length; li++) {
      final String line = lines[li];
      if (line.trim().isEmpty) {
        continue;
      }
      final List<String> cells = _splitTsvLine(line);
      final String a = _cell(cells, iA);
      final String b = _cell(cells, iB);
      final String res = _cell(cells, iRes);
      if (a.isEmpty || b.isEmpty || res.isEmpty) {
        continue;
      }
      _ensureCard(root, a);
      _ensureCard(root, b);
      _ensureCard(root, res);
      _addDirectedEdge(root, a, b, res);
      _addDirectedEdge(root, b, a, res);
      if (iBa0 != null && iBd0 != null) {
        final int atk = _readIntCell(cells, iBa0);
        final int def = _readIntCell(cells, iBd0);
        final String rarity = iResRare != null
            ? _rarityFromCode(_readIntCell(cells, iResRare))
            : '';
        _applyResultRow(root, res, attack: atk, defense: def, rarity: rarity);
      }
    }
    return root;
  }

  static List<String> _splitTsvLine(String line) {
    return line.split('\t');
  }

  static String _cell(List<String> cells, int index) {
    if (index < 0 || index >= cells.length) {
      return '';
    }
    return cells[index].trim();
  }

  static int _readIntCell(List<String> cells, int index) {
    final String s = _cell(cells, index);
    if (s.isEmpty) {
      return 0;
    }
    final String cleaned = s.replaceAll(',', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  /// Result rarity codes in export (1-4).
  static String _rarityFromCode(int code) {
    switch (code) {
      case 1:
        return 'Common';
      case 2:
        return 'Uncommon';
      case 3:
        return 'Rare';
      case 4:
        return 'Diamond';
      default:
        return '';
    }
  }

  static void _ensureCard(Map<String, Object?> root, String cardId) {
    if (cardId.isEmpty) {
      return;
    }
    if (root.containsKey(cardId)) {
      return;
    }
    root[cardId] = <String, Object?>{
      'DisplayName': cardId,
      'Attack': 0,
      'Defense': 0,
      'Rarity': '',
      'FusionAbility': '',
      'Picture': '',
      'CardNum': '',
      'Description': '',
      'Combinations': <String, Object?>{},
      'isLTE': false,
    };
  }

  static void _addDirectedEdge(
    Map<String, Object?> root,
    String fromId,
    String toId,
    String resultId,
  ) {
    final Object? raw = root[fromId];
    if (raw is! Map) {
      return;
    }
    final Map<String, Object?> card = _asStringKeyedMap(raw);
    final Map<String, Object?> comb = _combinationsMap(card['Combinations']);
    comb[toId] = resultId;
    card['Combinations'] = comb;
    root[fromId] = card;
  }

  static void _applyResultRow(
    Map<String, Object?> root,
    String resId, {
    required int attack,
    required int defense,
    required String rarity,
  }) {
    final Object? raw = root[resId];
    if (raw is! Map) {
      return;
    }
    final Map<String, Object?> card = _asStringKeyedMap(raw);
    card['Attack'] = attack;
    card['Defense'] = defense;
    if (rarity.isNotEmpty) {
      card['Rarity'] = rarity;
    }
    root[resId] = card;
  }

  static Map<String, Object?> _asStringKeyedMap(Object? raw) {
    if (raw is! Map) {
      return <String, Object?>{};
    }
    final Map<String, Object?> out = <String, Object?>{};
    raw.forEach((Object? k, Object? v) {
      out[k.toString()] = v;
    });
    return out;
  }

  static Map<String, Object?> _combinationsMap(Object? raw) {
    if (raw is Map) {
      final Map<String, Object?> out = <String, Object?>{};
      raw.forEach((Object? k, Object? v) {
        out[k.toString()] = v;
      });
      return out;
    }
    return <String, Object?>{};
  }

  /// For debugging: serialization does not guarantee stable key order.
  static String rootMapToJsonString(Map<String, Object?> root) {
    return const JsonEncoder.withIndent('  ').convert(root);
  }
}
