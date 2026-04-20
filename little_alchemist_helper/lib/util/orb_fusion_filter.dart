import '../models/alchemy_card.dart';

/// Mirrors Excel Power Query: only cards with
/// [AlchemyCard.fusionAbility] == `"Orb"` (case- and whitespace-insensitive) participate.
bool fusionAbilityIsOrb(String fusionAbility) {
  return fusionAbility.trim().toLowerCase() == 'orb';
}

/// Removes [combinations] edges where source or partner is not Orb, matching
/// `FusionAbility = "Orb"` in Excel **CMB** / **Combo List** queries.
///
/// Call this **before** [normalizeUndirectedFusionGraph] so reverse edges
/// are generated only for Orb+Orb pairs.
Map<String, AlchemyCard> retainOnlyOrbFusionCombinations(
  Map<String, AlchemyCard> catalog,
) {
  final Map<String, AlchemyCard> out = <String, AlchemyCard>{};
  for (final MapEntry<String, AlchemyCard> e in catalog.entries) {
    final AlchemyCard c = e.value;
    if (!fusionAbilityIsOrb(c.fusionAbility)) {
      out[e.key] = c.combinations.isEmpty
          ? c
          : c.copyWith(combinations: <String, String>{});
      continue;
    }
    final Map<String, String> next = <String, String>{};
    for (final MapEntry<String, String> ce in c.combinations.entries) {
      final AlchemyCard? partner = catalog[ce.key];
      if (partner != null && fusionAbilityIsOrb(partner.fusionAbility)) {
        next[ce.key] = ce.value;
      }
    }
    out[e.key] = c.copyWith(combinations: next);
  }
  return out;
}
