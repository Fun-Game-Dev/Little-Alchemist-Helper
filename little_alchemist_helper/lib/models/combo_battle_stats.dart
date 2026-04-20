import 'dart:math' as math;

import 'combo_tier.dart';

/// Computes combo result level and battle stats for Orb fusion.
///
/// Rules match the wiki model (result level from material levels and result
/// rarity; per-level A/D from **highest** material tier; half/full onyx
/// one-time boosts — Tables 1–3 in `assets/LA_v5-11_excel_technical_documentation.md`
/// §8). See also [Card Mechanics](https://lil-alchemist.fandom.com/wiki/Card_Mechanics).
class ComboBattleStats {
  const ComboBattleStats._();

  /// Max level used for **attack/defense scaling** from base stats.
  ///
  /// Fused cards use UI level 6 but in-game A/D do not grow beyond level-5 values.
  static const int maxStatScalingLevel = 5;

  /// Combo **result** rarity (the card produced by the pair).
  static bool isLowTierComboResult(ComboTier resultTier) {
    return resultTier == ComboTier.bronze || resultTier == ComboTier.silver;
  }

  /// Result level: average material levels, rounded up;
  /// gold/diamond/onyx results get +1; cap is 5 or 6.
  static int resultLevel({
    required int materialLevelA,
    required int materialLevelB,
    required ComboTier resultTier,
    ComboResultOnyxShape onyxShape = ComboResultOnyxShape.none,
  }) {
    final int la = materialLevelA.clamp(1, 5);
    final int lb = materialLevelB.clamp(1, 5);
    final double avg = (la + lb) / 2.0;
    int v = avg.ceil();
    final bool lowResult = isLowTierComboResult(resultTier);
    final bool highLikeResult =
        !lowResult || onyxShape != ComboResultOnyxShape.none;
    if (highLikeResult) {
      v += 1;
    }
    final int cap = lowResult && onyxShape == ComboResultOnyxShape.none ? 5 : 6;
    return v.clamp(1, cap);
  }

  /// A/D gain for each result level above 1 based on the maximum
  /// **material** rarity (not the result rarity).
  static ({int attack, int defense}) perLevelBonus(ComboTier highestMaterial) {
    switch (highestMaterial) {
      case ComboTier.bronze:
        return (attack: 1, defense: 1);
      case ComboTier.silver:
        return (attack: 2, defense: 2);
      case ComboTier.gold:
        return (attack: 3, defense: 3);
      case ComboTier.diamond:
        return (attack: 4, defense: 4);
      case ComboTier.onyx:
        return (attack: 4, defense: 4);
    }
  }

  /// Result stats after level scaling (without one-time half/full onyx bonuses).
  static ({int attack, int defense}) scaledResultStats({
    required int resultBaseAttack,
    required int resultBaseDefense,
    required int resultLevel,
    required ComboTier highestMaterialTier,
  }) {
    final int lvl = resultLevel.clamp(1, maxStatScalingLevel);
    final int steps = math.max(0, lvl - 1);
    final ({int attack, int defense}) d = perLevelBonus(highestMaterialTier);
    return (
      attack: resultBaseAttack + d.attack * steps,
      defense: resultBaseDefense + d.defense * steps,
    );
  }

  /// One-time half/full onyx bonus (wiki table 3); [originalResultTier] is the
  /// original combo-result rarity before adding the onyx shell.
  static ({int attack, int defense})? onyxTable3Bonus({
    required ComboResultOnyxShape shape,
    required ComboTier originalResultTier,
  }) {
    if (shape == ComboResultOnyxShape.none) {
      return null;
    }
    final Map<ComboTier, ({int halfA, int halfD, int fullA, int fullD})> rows =
        <ComboTier, ({int halfA, int halfD, int fullA, int fullD})>{
          ComboTier.bronze: (halfA: 27, halfD: 27, fullA: 29, fullD: 29),
          ComboTier.silver: (halfA: 25, halfD: 25, fullA: 27, fullD: 27),
          ComboTier.gold: (halfA: 23, halfD: 23, fullA: 25, fullD: 25),
          ComboTier.diamond: (halfA: 20, halfD: 20, fullA: 23, fullD: 23),
          ComboTier.onyx: (halfA: 20, halfD: 20, fullA: 23, fullD: 23),
        };
    final ({int halfA, int halfD, int fullA, int fullD})? row =
        rows[originalResultTier];
    if (row == null) {
      return null;
    }
    return shape == ComboResultOnyxShape.half
        ? (attack: row.halfA, defense: row.halfD)
        : (attack: row.fullA, defense: row.fullD);
  }
}

/// Shape of an onyx result (catalog often has no separate rarity row).
enum ComboResultOnyxShape { none, half, full }
