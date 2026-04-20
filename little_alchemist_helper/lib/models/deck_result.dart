import 'package:flutter/foundation.dart';

import 'alchemy_card.dart';
import 'owned_combo_entry.dart';

/// One slot in an optimized deck: catalog card plus collection instance.
@immutable
class DeckPlannedSlot {
  const DeckPlannedSlot({required this.catalogCard, required this.entry});

  final AlchemyCard catalogCard;
  final OwnedComboEntry entry;
}

@immutable
class DeckOptimizationResult {
  const DeckOptimizationResult({
    required this.slots,
    required this.totalScore,
    required this.soloScore,
    required this.fusionScore,
    required this.comboMergeScore,
    required this.poolTruncated,
    required this.consideredCount,
    required this.usedHeuristic,
  });

  final List<DeckPlannedSlot> slots;
  final double totalScore;
  final double soloScore;
  final double fusionScore;

  /// Contribution = weight x sum of pair fusion scores (1/2/3 with fused adjustment).
  final double comboMergeScore;
  final bool poolTruncated;
  final int consideredCount;

  /// Exhaustive search is not feasible (large deck/pool); uses greedy selection plus refinement.
  final bool usedHeuristic;
}
