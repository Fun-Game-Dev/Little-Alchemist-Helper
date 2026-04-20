import 'combo_tier.dart';
import 'owned_combo_entry.dart';

/// Material selection on Combo screen (same shape as collection instance: tier + level).
class ComboLabMaterialPick {
  const ComboLabMaterialPick({
    required this.cardId,
    required this.tier,
    required this.level,
  });

  final String cardId;
  final ComboTier tier;
  final int level;

  bool get isFused => level >= OwnedComboEntry.fusedLevel;

  /// Material level used for battle combo calculation (1-5; fused counts as 5).
  int get battleMaterialLevel {
    if (level >= OwnedComboEntry.fusedLevel) {
      return 5;
    }
    return level.clamp(OwnedComboEntry.minLevel, 5);
  }
}
