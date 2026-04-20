import 'alchemy_card.dart';

/// Rarity of a combo-card **instance** in collection (in-game tiers).
/// Catalog JSON rarity: Common / Uncommon / Rare / Diamond / (optional) Onyx, see [comboTierFromCatalogRarity].
enum ComboTier { bronze, silver, gold, diamond, onyx }

extension ComboTierLabels on ComboTier {
  String get nameForStorage {
    switch (this) {
      case ComboTier.bronze:
        return 'bronze';
      case ComboTier.silver:
        return 'silver';
      case ComboTier.gold:
        return 'gold';
      case ComboTier.diamond:
        return 'diamond';
      case ComboTier.onyx:
        return 'onyx';
    }
  }

  /// Sort order: bronze -> onyx.
  int get sortIndex {
    switch (this) {
      case ComboTier.bronze:
        return 0;
      case ComboTier.silver:
        return 1;
      case ComboTier.gold:
        return 2;
      case ComboTier.diamond:
        return 3;
      case ComboTier.onyx:
        return 4;
    }
  }
}

ComboTier? comboTierFromStorageName(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'bronze':
    case 'common':
      return ComboTier.bronze;
    case 'silver':
    case 'uncommon':
      return ComboTier.silver;
    case 'gold':
    case 'rare':
      return ComboTier.gold;
    case 'diamond':
      return ComboTier.diamond;
    case 'onyx':
    case 'onix':
      return ComboTier.onyx;
    default:
      return null;
  }
}

/// Mapping for [AlchemyCard.rarity] in catalog data.
ComboTier comboTierFromCatalogRarity(String rarity) {
  final ComboTier? t = comboTierFromStorageName(rarity);
  return t ?? ComboTier.bronze;
}

/// Maximum allowed instance tier for the catalog row rarity.
ComboTier maxInstanceTierForCatalogCard(AlchemyCard card) {
  return comboTierFromCatalogRarity(card.rarity);
}

/// Clamps selected instance tier to catalog-allowed value for the card.
ComboTier clampInstanceTierToCatalog(AlchemyCard card, ComboTier tier) {
  final ComboTier max = maxInstanceTierForCatalogCard(card);
  if (tier.sortIndex <= max.sortIndex) {
    return tier;
  }
  return max;
}

/// Instance tiers allowed for a card (not above catalog data rarity).
List<ComboTier> allowedInstanceTiersForCatalogCard(AlchemyCard card) {
  final ComboTier max = maxInstanceTierForCatalogCard(card);
  return ComboTier.values
      .where((ComboTier t) => t.sortIndex <= max.sortIndex)
      .toList();
}
