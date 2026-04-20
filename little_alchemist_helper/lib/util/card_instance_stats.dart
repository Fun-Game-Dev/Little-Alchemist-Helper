import '../models/alchemy_card.dart';
import '../models/combo_battle_stats.dart';
import '../models/combo_tier.dart';
import '../models/owned_combo_entry.dart';

/// Display stats for one concrete card instance (catalog base + level growth).
({int attack, int defense}) scaledCardInstanceStats({
  required AlchemyCard card,
  required ComboTier tier,
  required int level,
}) {
  final int clampedLevel = level.clamp(
    OwnedComboEntry.minLevel,
    OwnedComboEntry.maxLevel,
  );
  return ComboBattleStats.scaledResultStats(
    resultBaseAttack: card.attack,
    resultBaseDefense: card.defense,
    resultLevel: clampedLevel,
    highestMaterialTier: tier,
  );
}
