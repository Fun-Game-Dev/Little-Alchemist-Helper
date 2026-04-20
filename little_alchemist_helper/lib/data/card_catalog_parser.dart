import 'dart:convert';

import '../models/alchemy_card.dart';
import '../services/fusion_graph_normalizer.dart';
import '../util/orb_fusion_filter.dart';
import 'catalog_json_merge.dart';

/// Parses [AlchemyCardData.json] into a card catalog.
class CardCatalogParser {
  const CardCatalogParser();

  /// [combinationPatchJson] is an optional JSON in catalog format;
  /// only [Combinations] blocks are merged (see [mergeCombinationPatchIntoRoot]).
  Map<String, AlchemyCard> parseJsonString(
    String raw, {
    String combinationPatchJson = '',
  }) {
    final Map<String, Object?> root = _decodeRootObjectMap(raw);
    final String trimmedPatch = combinationPatchJson.trim();
    if (trimmedPatch.isNotEmpty && trimmedPatch != '{}') {
      final Map<String, Object?> patch = _decodeRootObjectMap(
        combinationPatchJson,
      );
      mergeCombinationPatchIntoRoot(root, patch);
    }
    final Map<String, AlchemyCard> out = <String, AlchemyCard>{};
    for (final MapEntry<String, Object?> e in root.entries) {
      final Object? value = e.value;
      if (value is Map) {
        final Map<String, Object?> m = <String, Object?>{};
        value.forEach((Object? k, Object? v) {
          m[k.toString()] = v;
        });
        out[e.key] = _parseCard(e.key, m);
      }
    }
    final Map<String, AlchemyCard> orbOnly =
        retainOnlyOrbFusionCombinations(out);
    return normalizeUndirectedFusionGraph(orbOnly);
  }

  Future<Map<String, AlchemyCard>> parseJsonStringAsync(
    String raw, {
    String combinationPatchJson = '',
  }) async {
    return parseJsonString(raw, combinationPatchJson: combinationPatchJson);
  }

  Map<String, Object?> _decodeRootObjectMap(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Ожидался JSON-объект с картами');
    }
    final Map<String, Object?> root = <String, Object?>{};
    decoded.forEach((Object? k, Object? v) {
      root[k.toString()] = v;
    });
    return root;
  }

  AlchemyCard _parseCard(String cardId, Map<String, Object?> m) {
    final String displayName =
        (m['DisplayName'] as String?)?.trim().isNotEmpty == true
        ? (m['DisplayName'] as String).trim()
        : cardId;
    final int attack = _readInt(m['Attack']);
    final int defense = _readInt(m['Defense']);
    final String rarity = (m['Rarity'] as String?)?.trim() ?? '';
    final String fusionAbility = (m['FusionAbility'] as String?)?.trim() ?? '';
    final String pictureKey = (m['Picture'] as String?)?.trim() ?? cardId;
    final String cardNum = (m['CardNum'] as String?)?.trim() ?? '';
    final String description = (m['Description'] as String?)?.trim() ?? '';
    final Map<String, String> combinations = _parseCombinations(
      m['Combinations'],
    );
    final bool isLte = m['isLTE'] == true;
    final String? seasonalTag = _readSeasonal(m['isSeasonal']);
    return AlchemyCard(
      cardId: cardId,
      displayName: displayName,
      attack: attack,
      defense: defense,
      rarity: rarity,
      fusionAbility: fusionAbility,
      pictureKey: pictureKey,
      cardNum: cardNum,
      description: description,
      combinations: combinations,
      isLte: isLte,
      seasonalTag: seasonalTag,
    );
  }

  static Map<String, String> _parseCombinations(Object? raw) {
    if (raw is! Map) {
      return <String, String>{};
    }
    final Map<String, String> out = <String, String>{};
    raw.forEach((Object? k, Object? v) {
      if (k is String && v is String) {
        out[k] = v;
      }
    });
    return out;
  }

  static int _readInt(Object? v) {
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    return 0;
  }

  static String? _readSeasonal(Object? v) {
    if (v is String && v.trim().isNotEmpty) {
      return v.trim();
    }
    return null;
  }
}
