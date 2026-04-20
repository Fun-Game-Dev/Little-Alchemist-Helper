/// Merges [Combinations] from [patch] into [base] cards.
///
/// [patch] uses the same format as the main catalog: key is [cardId], value is
/// a card object; only [Combinations] are applied. Missing [cardId] in [base]
/// are ignored. Patch values override existing pairs.
void mergeCombinationPatchIntoRoot(
  Map<String, Object?> base,
  Map<String, Object?> patch,
) {
  for (final MapEntry<String, Object?> pe in patch.entries) {
    final String cardId = pe.key;
    final Object? patchCard = pe.value;
    if (patchCard is! Map) {
      continue;
    }
    final Object? baseCard = base[cardId];
    if (baseCard is! Map) {
      continue;
    }
    final Map<String, Object?> baseMap = <String, Object?>{};
    baseCard.forEach((Object? k, Object? v) {
      baseMap[k.toString()] = v;
    });
    final Object? pComb = patchCard['Combinations'];
    if (pComb is! Map) {
      continue;
    }
    final Map<String, Object?> mergedComb = <String, Object?>{};
    final Object? oldComb = baseMap['Combinations'];
    if (oldComb is Map) {
      oldComb.forEach((Object? k, Object? v) {
        mergedComb[k.toString()] = v;
      });
    }
    pComb.forEach((Object? k, Object? v) {
      if (k is String && v is String) {
        mergedComb[k] = v;
      }
    });
    baseMap['Combinations'] = mergedComb;
    base[cardId] = baseMap;
  }
}

/// Merges full JSON catalog [patch] into [base]: for each card in patch,
/// fields override base; [Combinations] are merged by keys (patch wins).
/// Cards present only in patch are added as-is.
void mergeFullCatalogPatchIntoRoot(
  Map<String, Object?> base,
  Map<String, Object?> patch,
) {
  for (final MapEntry<String, Object?> pe in patch.entries) {
    final String cardId = pe.key;
    final Object? patchCard = pe.value;
    if (patchCard is! Map) {
      continue;
    }
    final Object? baseCard = base[cardId];
    if (baseCard is Map) {
      base[cardId] = _mergeCardMaps(
        jsonMapToStringKeyed(baseCard),
        jsonMapToStringKeyed(patchCard),
      );
    } else {
      base[cardId] = _cloneJsonMap(patchCard);
    }
  }
}

Map<String, Object?> jsonMapToStringKeyed(Object? raw) {
  if (raw is! Map) {
    return <String, Object?>{};
  }
  final Map<String, Object?> out = <String, Object?>{};
  raw.forEach((Object? k, Object? v) {
    out[k.toString()] = v;
  });
  return out;
}

Map<String, Object?> _cloneJsonMap(Object? raw) {
  final Map<String, Object?> m = jsonMapToStringKeyed(raw);
  final Map<String, Object?> out = <String, Object?>{};
  for (final MapEntry<String, Object?> e in m.entries) {
    out[e.key] = _cloneJsonValue(e.value);
  }
  return out;
}

Object? _cloneJsonValue(Object? v) {
  if (v is Map) {
    return _cloneJsonMap(v);
  }
  if (v is List) {
    return v.map(_cloneJsonValue).toList();
  }
  return v;
}

Map<String, Object?> _mergeCardMaps(
  Map<String, Object?> base,
  Map<String, Object?> patch,
) {
  final Map<String, Object?> out = _cloneJsonMap(base);
  for (final MapEntry<String, Object?> pe in patch.entries) {
    final String key = pe.key;
    final Object? pv = pe.value;
    if (key == 'Combinations') {
      final Map<String, Object?> merged = jsonMapToStringKeyed(out['Combinations']);
      final Map<String, Object?> pComb = jsonMapToStringKeyed(pv);
      merged.addAll(pComb);
      out['Combinations'] = merged;
      continue;
    }
    if (pv is Map && out[key] is Map) {
      out[key] = _mergeCardMaps(
        jsonMapToStringKeyed(out[key]),
        jsonMapToStringKeyed(pv),
      );
    } else {
      out[key] = _cloneJsonValue(pv);
    }
  }
  return out;
}

/// Whether it makes sense to write patch value (source is not empty).
bool isNonEmptyCatalogFieldValue(String fieldKey, Object? v) {
  if (v == null) {
    return false;
  }
  if (v is String) {
    return v.trim().isNotEmpty;
  }
  if (v is Map) {
    return v.isNotEmpty;
  }
  if (v is List) {
    return v.isNotEmpty;
  }
  return true;
}

/// Resolves card key in [primary] for Excel/TSV cells (CC_A, CC_B, Res).
///
/// First tries a card with [DisplayName] == [name] (both in-game and Power Query
/// use display names). Otherwise tries exact JSON key match.
/// Otherwise returns [name] (new placeholder from export).
///
/// Important: key `"Hybrid"` is Werevamp (Siphon), while the Orb combo card named
/// "Hybrid" in data is a separate card `HybridCombo`; TSV cell `Hybrid`
/// must resolve by [DisplayName], not by first matching key.
String canonicalCardKeyForCellName(
  String name,
  Map<String, Object?> primary,
) {
  final String t = name.trim();
  if (t.isEmpty) {
    return name;
  }
  for (final MapEntry<String, Object?> e in primary.entries) {
    final Object? cv = e.value;
    if (cv is! Map) {
      continue;
    }
    final Map<String, Object?> m = jsonMapToStringKeyed(cv);
    final String dn = (m['DisplayName'] as String?)?.trim() ?? '';
    if (dn == t) {
      return e.key;
    }
  }
  if (primary.containsKey(t)) {
    return t;
  }
  return t;
}

/// Extends [primary] with Excel data: adds new cards; for existing cards,
/// merges [Combinations] and fills only empty fields (does not overwrite JSON).
///
/// TSV names are normalized to [primary] keys via [canonicalCardKeyForCellName],
/// to match Power Query behavior (internal key vs display name).
void mergeExcelSupplementIntoRoot(
  Map<String, Object?> primary,
  Map<String, Object?> excelRoot,
) {
  for (final MapEntry<String, Object?> ee in excelRoot.entries) {
    final String excelKey = ee.key;
    final Object? exRaw = ee.value;
    if (exRaw is! Map) {
      continue;
    }
    final Map<String, Object?> ex = jsonMapToStringKeyed(exRaw);
    final String targetKey = canonicalCardKeyForCellName(excelKey, primary);
    if (!primary.containsKey(targetKey)) {
      final Map<String, Object?> exRemapped = _remapExcelCardCombinationKeys(
        ex,
        primary,
      );
      primary[targetKey] = _cloneJsonMap(exRemapped);
      continue;
    }
    final Object? pRaw = primary[targetKey];
    if (pRaw is! Map) {
      continue;
    }
    final Map<String, Object?> base = jsonMapToStringKeyed(pRaw);
    final Map<String, Object?> bComb = jsonMapToStringKeyed(base['Combinations']);
    final Map<String, Object?> eComb = jsonMapToStringKeyed(ex['Combinations']);
    for (final MapEntry<String, Object?> ce in eComb.entries) {
      final String partnerKey = canonicalCardKeyForCellName(ce.key, primary);
      bComb[partnerKey] = ce.value;
    }
    base['Combinations'] = bComb;
    for (final MapEntry<String, Object?> fe in ex.entries) {
      if (fe.key == 'Combinations') {
        continue;
      }
      if (isNonEmptyCatalogFieldValue(fe.key, base[fe.key])) {
        continue;
      }
      if (isNonEmptyCatalogFieldValue(fe.key, fe.value)) {
        base[fe.key] = _cloneJsonValue(fe.value);
      }
    }
    primary[targetKey] = base;
  }
}

Map<String, Object?> _remapExcelCardCombinationKeys(
  Map<String, Object?> ex,
  Map<String, Object?> primary,
) {
  final Map<String, Object?> out = _cloneJsonMap(ex);
  final Object? comb = ex['Combinations'];
  if (comb is! Map) {
    return out;
  }
  final Map<String, Object?> remapped = <String, Object?>{};
  comb.forEach((Object? k, Object? v) {
    final String pk = canonicalCardKeyForCellName(k.toString(), primary);
    remapped[pk] = v;
  });
  out['Combinations'] = remapped;
  return out;
}

/// User JSON patch: additive only (new cards and empty fields),
/// [Combinations] are merged with patch-key precedence.
void mergeSupplementCatalogPatchIntoRoot(
  Map<String, Object?> base,
  Map<String, Object?> patch,
) {
  for (final MapEntry<String, Object?> pe in patch.entries) {
    final String cardId = pe.key;
    final Object? patchCard = pe.value;
    if (patchCard is! Map) {
      continue;
    }
    final Map<String, Object?> p = jsonMapToStringKeyed(patchCard);
    if (!base.containsKey(cardId)) {
      base[cardId] = _cloneJsonMap(p);
      continue;
    }
    final Object? bRaw = base[cardId];
    if (bRaw is! Map) {
      continue;
    }
    final Map<String, Object?> out = jsonMapToStringKeyed(bRaw);
    final Map<String, Object?> mergedComb = jsonMapToStringKeyed(out['Combinations']);
    mergedComb.addAll(jsonMapToStringKeyed(p['Combinations']));
    out['Combinations'] = mergedComb;
    for (final MapEntry<String, Object?> fe in p.entries) {
      if (fe.key == 'Combinations') {
        continue;
      }
      if (isNonEmptyCatalogFieldValue(fe.key, out[fe.key])) {
        continue;
      }
      if (isNonEmptyCatalogFieldValue(fe.key, fe.value)) {
        out[fe.key] = _cloneJsonValue(fe.value);
      }
    }
    base[cardId] = out;
  }
}
