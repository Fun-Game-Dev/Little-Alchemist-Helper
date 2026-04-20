import 'dart:convert';

/// Combo-result stats table for 0 / 1 / 2 onyx materials (from Excel export).
///
/// Key is [pairKey] from two catalog [cardId] values; value is three [attack, defense] pairs.
class FusionOnyxSheet {
  FusionOnyxSheet._(this._byKey);

  final Map<String, List<List<int>>> _byKey;

  static String pairKey(String cardIdA, String cardIdB) {
    if (cardIdA.compareTo(cardIdB) <= 0) {
      return '$cardIdA|$cardIdB';
    }
    return '$cardIdB|$cardIdA';
  }

  /// [attack, defense] pair for [onyxMaterialCount] in 0...2, or null.
  List<int>? resultAttackDefense(
    String cardIdA,
    String cardIdB,
    int onyxMaterialCount,
  ) {
    final List<List<int>>? row = _byKey[pairKey(cardIdA, cardIdB)];
    if (row == null) {
      return null;
    }
    final int i = onyxMaterialCount.clamp(0, 2);
    if (i >= row.length) {
      return null;
    }
    final List<int> p = row[i];
    if (p.length < 2) {
      return null;
    }
    return <int>[p[0], p[1]];
  }

  void forEachEntry(
    void Function(String pairKey, List<List<int>> triple) onPair,
  ) {
    _byKey.forEach(onPair);
  }

  static FusionOnyxSheet? parse(String raw) {
    final String t = raw.trim();
    if (t.isEmpty) {
      return null;
    }
    final Object? decoded = jsonDecode(t);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    final Map<String, List<List<int>>> out = <String, List<List<int>>>{};
    decoded.forEach((String k, Object? v) {
      if (v is! List) {
        return;
      }
      final List<List<int>> triple = <List<int>>[];
      for (final Object? row in v) {
        if (row is! List || row.length < 2) {
          return;
        }
        final int? a = (row[0] as num?)?.toInt();
        final int? d = (row[1] as num?)?.toInt();
        if (a == null || d == null) {
          return;
        }
        triple.add(<int>[a, d]);
      }
      if (triple.length == 3) {
        out[k] = triple;
      }
    });
    if (out.isEmpty) {
      return null;
    }
    return FusionOnyxSheet._(out);
  }

  /// Sum of result attack and defense; [onyxMaterialCount] is number of onyx-tier materials (0-2).
  int? resultSumStats(String cardIdA, String cardIdB, int onyxMaterialCount) {
    final List<List<int>>? row = _byKey[pairKey(cardIdA, cardIdB)];
    if (row == null) {
      return null;
    }
    final int i = onyxMaterialCount.clamp(0, 2);
    if (i >= row.length) {
      return null;
    }
    final List<int> p = row[i];
    if (p.length < 2) {
      return null;
    }
    return p[0] + p[1];
  }
}
