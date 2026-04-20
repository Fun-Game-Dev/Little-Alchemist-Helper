import '../models/alchemy_card.dart';
import '../services/combo_graph_lookup.dart';
import '../services/fusion_graph_normalizer.dart';
import '../util/catalog_fusion.dart';
import 'fusion_onyx_sheet.dart';

/// Synthetic onyx catalog rows:
/// 1) **Materials**: combo-card copies with the same fusion edges as the base rarity,
///    but with increased A/D and [Rarity] set to Onyx (same recipes, different stats).
/// 2) **Result of two onyx materials**: use [FusionOnyxSheet] slot 2 for combo result stats.
class SyntheticOnyxCatalogAugment {
  SyntheticOnyxCatalogAugment._();

  static const String materialOnyxPrefix = '__lah_mat_onyx__';
  static const String fullResultIdPrefix = '__lah_syn_ox2__';

  /// Identifier of the synthetic **material** onyx copy for base card [baseCardId].
  static String materialOnyxId(String baseCardId) =>
      '$materialOnyxPrefix$baseCardId';

  static bool isSyntheticOnyxFusionResultCardId(String cardId) {
    return cardId.startsWith(fullResultIdPrefix);
  }

  static bool isSyntheticMaterialOnyxCardId(String cardId) {
    return cardId.startsWith(materialOnyxPrefix);
  }

  /// Any synthetic row added by this module.
  static bool isSyntheticOnyxCatalogId(String cardId) {
    return isSyntheticMaterialOnyxCardId(cardId) ||
        isSyntheticOnyxFusionResultCardId(cardId);
  }

  static String? baseFusionResultIdFromSynthetic(String cardId) {
    if (cardId.startsWith(fullResultIdPrefix)) {
      return cardId.substring(fullResultIdPrefix.length);
    }
    return null;
  }

  /// Base catalog card ID used for [FusionOnyxSheet] keys (original export IDs).
  static String canonicalCatalogIdForFusionSheet(String cardId) {
    if (cardId.startsWith(materialOnyxPrefix)) {
      return cardId.substring(materialOnyxPrefix.length);
    }
    if (cardId.startsWith(fullResultIdPrefix)) {
      return baseFusionResultIdFromSynthetic(cardId) ?? cardId;
    }
    return cardId;
  }

  static String fullIdForFusionResult(String resultCardId) =>
      '$fullResultIdPrefix$resultCardId';

  /// For each partner pair in [combinations], duplicates the key with the partner onyx-copy ID,
  /// so "onyx + onyx" fusion resolves to the same [resultId] as base cards.
  ///
  /// Aliases are added only for partners in [materialOnyxEligibleBaseIds] (карты, для которых
  /// вообще существует синтетический материал Onyx).
  static Map<String, String> expandCombinationsWithOnyxMaterialAliases(
    Map<String, String> combinations, {
    required Set<String> materialOnyxEligibleBaseIds,
  }) {
    final Map<String, String> out = Map<String, String>.from(combinations);
    for (final MapEntry<String, String> e in combinations.entries) {
      final String partnerId = e.key;
      final String resultId = e.value;
      if (partnerId.startsWith('__lah_')) {
        continue;
      }
      if (!materialOnyxEligibleBaseIds.contains(partnerId)) {
        continue;
      }
      out[materialOnyxId(partnerId)] = resultId;
    }
    return out;
  }

  /// Aggregates by [resultCardId]: for each slot 0/1/2 keeps the A/D pair with larger sum.
  static Map<String, List<List<int>>> aggregateTriplesByFusionResult({
    required Map<String, AlchemyCard> catalog,
    required FusionOnyxSheet sheet,
  }) {
    final Map<String, List<List<int>>> byResult =
        <String, List<List<int>>>{};
    sheet.forEachEntry((String pairKey, List<List<int>> triple) {
      if (triple.length != 3) {
        return;
      }
      final int pipe = pairKey.indexOf('|');
      if (pipe <= 0 || pipe >= pairKey.length - 1) {
        return;
      }
      final String idA = pairKey.substring(0, pipe);
      final String idB = pairKey.substring(pipe + 1);
      final AlchemyCard? a = catalog[idA];
      final AlchemyCard? b = catalog[idB];
      if (a == null || b == null) {
        return;
      }
      final String? rid = ComboGraphLookup.fusionResultCardId(a, b);
      if (rid == null || rid.isEmpty) {
        return;
      }
      final AlchemyCard? resultCard = catalog[rid];
      if (resultCard == null) {
        return;
      }
      final List<List<int>>? prev = byResult[rid];
      if (prev == null) {
        byResult[rid] = triple
            .map((List<int> p) => List<int>.from(p))
            .toList(growable: false);
        return;
      }
      byResult[rid] = _mergeTripleMaxBySum(prev, triple);
    });
    return byResult;
  }

  static List<List<int>> _mergeTripleMaxBySum(
    List<List<int>> a,
    List<List<int>> b,
  ) {
    final List<List<int>> out = <List<int>>[];
    for (int i = 0; i < 3; i++) {
      out.add(_maxPairBySum(a[i], b[i]));
    }
    return out;
  }

  static List<int> _maxPairBySum(List<int> x, List<int> y) {
    int sum2(List<int> p) {
      if (p.length >= 2) {
        return p[0] + p[1];
      }
      if (p.length == 1) {
        return p[0];
      }
      return 0;
    }

    final List<int> pick = sum2(x) >= sum2(y) ? x : y;
    return <int>[
      pick.isNotEmpty ? pick[0] : 0,
      pick.length >= 2 ? pick[1] : 0,
    ];
  }

  /// A/D gain for an onyx **material** copy relative to the same card row in source data.
  ///
  /// Wiki: Common [Hammer (Onyx)] 8/5 at L1 vs 4/1 → +4/+4; Rare [Fairy Tale (Onyx)] 6/7 at L1
  /// vs 4/5 → +2/+2. Per-level scaling uses [ComboBattleStats.perLevelBonus] with onyx materials.
  static ({int attack, int defense}) materialOnyxStatDeltaForCatalogRarity(
    String rarity,
  ) {
    switch (rarity.trim()) {
      case 'Common':
      case 'common':
        return (attack: 4, defense: 4);
      case 'Uncommon':
      case 'uncommon':
        return (attack: 3, defense: 3);
      case 'Rare':
      case 'rare':
        return (attack: 2, defense: 2);
      case 'Diamond':
      case 'diamond':
        return (attack: 1, defense: 1);
      default:
        return (attack: 2, defense: 2);
    }
  }

  /// Extends the catalog: onyx materials for fusion participants whose [AlchemyCard.displayName]
  /// входит в [allowedOnyxMaterialDisplayNames] (основной источник — `assets/data/onyx_wiki_display_names.json`;
  /// при пустом парсе — `:occ:` из расписания / магазина), затем
  /// исходы «2 оникса» из [sheet] для тех же допустимых имён результата.
  static Map<String, AlchemyCard> mergeIntoCatalog({
    required Map<String, AlchemyCard> base,
    FusionOnyxSheet? sheet,
    required Set<String> allowedOnyxMaterialDisplayNames,
  }) {
    Map<String, AlchemyCard> out = Map<String, AlchemyCard>.from(base);
    final Set<String> eligibleBaseIds = _materialOnyxEligibleBaseCardIds(
      catalog: out,
      allowedOnyxMaterialDisplayNames: allowedOnyxMaterialDisplayNames,
    );
    out = _addMaterialOnyxCopies(out, eligibleBaseIds);
    if (sheet != null) {
      final Map<String, List<List<int>>> triplesByResult =
          aggregateTriplesByFusionResult(
        catalog: out,
        sheet: sheet,
      );
      for (final MapEntry<String, List<List<int>>> e in triplesByResult.entries) {
        final String rid = e.key;
        final List<List<int>> t = e.value;
        if (t.length < 3) {
          continue;
        }
        final AlchemyCard? template = out[rid];
        if (template == null) {
          continue;
        }
        if (!_displayNameAllowsSyntheticOnyx(
          template,
          allowedOnyxMaterialDisplayNames,
        )) {
          continue;
        }
        final List<int> full = t[2];
        if (full.length < 2) {
          continue;
        }
        final String fid = fullIdForFusionResult(rid);
        if (out.containsKey(materialOnyxId(rid))) {
          continue;
        }
        if (!out.containsKey(fid)) {
          out[fid] = _syntheticFusionResultFromTemplate(
            template: template,
            newCardId: fid,
            attack: full[0],
            defense: full[1],
            rarity: 'Onyx',
            displayNameSuffix: ' · оникс',
            materialOnyxEligibleBaseIds: eligibleBaseIds,
          );
        }
      }
    }
    return normalizeUndirectedFusionGraph(out);
  }

  static bool _displayNameAllowsSyntheticOnyx(
    AlchemyCard card,
    Set<String> allowedOnyxMaterialDisplayNames,
  ) {
    return allowedOnyxMaterialDisplayNames.contains(card.displayName.trim());
  }

  /// Базовые [cardId], для которых создаётся строка [materialOnyxId].
  static Set<String> _materialOnyxEligibleBaseCardIds({
    required Map<String, AlchemyCard> catalog,
    required Set<String> allowedOnyxMaterialDisplayNames,
  }) {
    final Set<String> participants = fusionParticipantCardIds(catalog);
    final Set<String> eligible = <String>{};
    for (final String id in participants) {
      if (id.startsWith('__lah_')) {
        continue;
      }
      final AlchemyCard? c = catalog[id];
      if (c == null) {
        continue;
      }
      if (_isLiteralOnyxRarityRow(c.rarity)) {
        continue;
      }
      if (!_displayNameAllowsSyntheticOnyx(c, allowedOnyxMaterialDisplayNames)) {
        continue;
      }
      eligible.add(id);
    }
    return eligible;
  }

  static Map<String, AlchemyCard> _addMaterialOnyxCopies(
    Map<String, AlchemyCard> catalog,
    Set<String> materialOnyxEligibleBaseIds,
  ) {
    final Map<String, AlchemyCard> out =
        Map<String, AlchemyCard>.from(catalog);
    for (final String id in materialOnyxEligibleBaseIds) {
      final String mid = materialOnyxId(id);
      if (out.containsKey(mid)) {
        continue;
      }
      final AlchemyCard? c = out[id];
      if (c == null) {
        continue;
      }
      out[mid] = _materialOnyxCardFrom(
        c,
        mid,
        materialOnyxEligibleBaseIds: materialOnyxEligibleBaseIds,
      );
    }
    return out;
  }

  static bool _isLiteralOnyxRarityRow(String rarity) {
    return rarity.trim().toLowerCase() == 'onyx';
  }

  static AlchemyCard _materialOnyxCardFrom(
    AlchemyCard c,
    String newCardId, {
    required Set<String> materialOnyxEligibleBaseIds,
  }) {
    final ({int attack, int defense}) d =
        materialOnyxStatDeltaForCatalogRarity(c.rarity);
    final String suffix = '';// ' · оникс';
    final String name = c.displayName.trim().endsWith(suffix.trim())
        ? c.displayName
        : '${c.displayName}$suffix';
    return c.copyWith(
      cardId: newCardId,
      displayName: name,
      attack: c.attack + d.attack,
      defense: c.defense + d.defense,
      rarity: 'Onyx',
      combinations: expandCombinationsWithOnyxMaterialAliases(
        c.combinations,
        materialOnyxEligibleBaseIds: materialOnyxEligibleBaseIds,
      ),
    );
  }

  static AlchemyCard _syntheticFusionResultFromTemplate({
    required AlchemyCard template,
    required String newCardId,
    required int attack,
    required int defense,
    required String rarity,
    required String displayNameSuffix,
    required Set<String> materialOnyxEligibleBaseIds,
  }) {
    final String suffix = template.displayName.trim().endsWith(
          displayNameSuffix.trim(),
        )
        ? ''
        : displayNameSuffix;
    return template.copyWith(
      cardId: newCardId,
      displayName: '${template.displayName}$suffix',
      attack: attack,
      defense: defense,
      rarity: rarity,
      combinations: expandCombinationsWithOnyxMaterialAliases(
        Map<String, String>.from(template.combinations),
        materialOnyxEligibleBaseIds: materialOnyxEligibleBaseIds,
      ),
    );
  }
}
