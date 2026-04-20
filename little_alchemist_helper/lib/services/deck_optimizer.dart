import 'dart:math' as math;

import '../data/collection_store.dart';
import '../data/excel_cc_order.dart';
import '../data/fusion_onyx_sheet.dart';
import '../data/synthetic_onyx_catalog_augment.dart';
import '../models/alchemy_card.dart';
import '../models/combo_tier.dart';
import '../models/deck_focus_preset.dart';
import '../models/deck_result.dart';
import '../models/deck_settings.dart';
import '../models/owned_combo_entry.dart';
import '../models/combo_battle_stats.dart';
import '../util/catalog_fusion.dart';
import 'combo_graph_lookup.dart';

/// In battle, the hand is [inGameHandSize] random cards from the deck; the
/// greedy step must not optimize only the sum of all [deck choose 2] pairs.
class DeckOptimizer {
  const DeckOptimizer();

  /// Little Alchemist: five cards in hand; random draw from the deck.
  static const int inGameHandSize = 5;

  /// Keeps expected bronze cards in a random hand to about one (see caps).
  static int _maxBronzeCardsForDeck(int deckSize) {
    return math.max(1, (deckSize + 4) ~/ 5);
  }

  /// Keeps expected silver in a random hand to roughly ~1.5 at cap.
  static int _maxSilverCardsForDeck(int deckSize) {
    return math.max(2, (deckSize * 3 + 9) ~/ 10);
  }

  /// Unit weight for "how strong is this instance alone in a random hand"
  /// (bronze/silver down-weighted so the deck is not full of weak random draws).
  static double _intrinsicTierHandUnit(ComboTier tier) {
    switch (tier) {
      case ComboTier.bronze:
        return 0.0;
      case ComboTier.silver:
        return 0.22;
      case ComboTier.gold:
        return 0.52;
      case ComboTier.diamond:
        return 0.78;
      case ComboTier.onyx:
        return 1.0;
    }
  }

  static double _handTierLineScore(ComboTier tier, int deckSize) {
    final double pInHand = inGameHandSize / math.max(deckSize, 1);
    return pInHand * _intrinsicTierHandUnit(tier);
  }

  DeckOptimizationResult? optimize({
    required Map<String, AlchemyCard> catalog,
    required List<OwnedComboEntry> ownedComboEntries,
    required DeckSettings settings,
    FusionOnyxSheet? fusionOnyxSheet,
  }) {
    final int k = settings.deckSize;
    if (k < DeckSettings.minDeckSize) {
      return null;
    }
    final Set<String> fusionParticipants = fusionParticipantCardIds(catalog);
    final List<_PoolSlot> pool = _expandPool(
      catalog: catalog,
      ownedComboEntries: ownedComboEntries,
      settings: settings,
      fusionParticipants: fusionParticipants,
    );
    if (pool.length < k) {
      return null;
    }
    pool.sort(_comparePoolSlotsExcelThenEntry);
    return _optimizeFromSeed(
      pool: pool,
      catalog: catalog,
      settings: settings,
      fusionOnyxSheet: fusionOnyxSheet,
    );
  }

  List<_PoolSlot> _expandPool({
    required Map<String, AlchemyCard> catalog,
    required List<OwnedComboEntry> ownedComboEntries,
    required DeckSettings settings,
    required Set<String> fusionParticipants,
  }) {
    final List<_PoolSlot> out = <_PoolSlot>[];
    for (final OwnedComboEntry e in ownedComboEntries) {
      final AlchemyCard? c = catalog[e.cardId];
      if (c == null || !fusionParticipants.contains(e.cardId)) {
        continue;
      }
      if (!_passesRarityRule(e, settings)) {
        continue;
      }
      out.add(_PoolSlot(card: c, entry: e));
    }
    return out;
  }

  bool _passesRarityRule(OwnedComboEntry e, DeckSettings settings) {
    final DeckRarityRule rule = settings.rarityRules.ruleFor(e.tier);
    return e.level >= rule.minLevel;
  }

  DeckOptimizationResult? _optimizeFromSeed({
    required List<_PoolSlot> pool,
    required Map<String, AlchemyCard> catalog,
    required DeckSettings settings,
    FusionOnyxSheet? fusionOnyxSheet,
  }) {
    final int k = settings.deckSize;
    final int? seedIndex = _findSeedIndex(pool, settings.seedEntryId);
    if (seedIndex == null) {
      return null;
    }
    final List<int> deckIndices = <int>[seedIndex];
    final Set<int> used = <int>{seedIndex};
    int nonFusedCount = pool[seedIndex].entry.isFused ? 0 : 1;
    final Map<String, int> groupCounts = <String, int>{
      pool[seedIndex].card.deckGroupKey: 1,
    };
    int bronzeInDeck = pool[seedIndex].entry.tier == ComboTier.bronze ? 1 : 0;
    int silverInDeck = pool[seedIndex].entry.tier == ComboTier.silver ? 1 : 0;
    final int maxBronze = _maxBronzeCardsForDeck(k);
    final int maxSilver = _maxSilverCardsForDeck(k);
    while (deckIndices.length < k) {
      int? bestIdx;
      _PickScore? bestScore;
      for (int capPhase = 0; capPhase < 2 && bestIdx == null; capPhase++) {
        final bool relaxTierCaps = capPhase > 0;
        for (int i = 0; i < pool.length; i++) {
          if (used.contains(i)) {
            continue;
          }
          final _PoolSlot candidate = pool[i];
          final String groupKey = candidate.card.deckGroupKey;
          if ((groupCounts[groupKey] ?? 0) >=
              CollectionStore.maxCopiesPerDeckGroupName) {
            continue;
          }
          if (!candidate.entry.isFused &&
              nonFusedCount >= settings.maxNonFusionCards) {
            continue;
          }
          if (!relaxTierCaps) {
            if (candidate.entry.tier == ComboTier.bronze &&
                bronzeInDeck >= maxBronze) {
              continue;
            }
            if (candidate.entry.tier == ComboTier.silver &&
                silverInDeck >= maxSilver) {
              continue;
            }
          }
          final _PickScore nextScore = _candidateScore(
            candidateIndex: i,
            deckIndices: deckIndices,
            pool: pool,
            catalog: catalog,
            settings: settings,
            fusionOnyxSheet: fusionOnyxSheet,
          );
          if (bestScore == null) {
            bestScore = nextScore;
            bestIdx = i;
            continue;
          }
          final int byScore = _comparePickScores(nextScore, bestScore, settings);
          if (byScore > 0 ||
              (byScore == 0 &&
                  bestIdx != null &&
                  _comparePoolIndexExcelThenEntry(pool, i, bestIdx) < 0)) {
            bestScore = nextScore;
            bestIdx = i;
          }
        }
      }
      if (bestIdx == null) {
        return null;
      }
      deckIndices.add(bestIdx);
      used.add(bestIdx);
      final _PoolSlot picked = pool[bestIdx];
      if (!picked.entry.isFused) {
        nonFusedCount++;
      }
      if (picked.entry.tier == ComboTier.bronze) {
        bronzeInDeck++;
      } else if (picked.entry.tier == ComboTier.silver) {
        silverInDeck++;
      }
      groupCounts[picked.card.deckGroupKey] =
          (groupCounts[picked.card.deckGroupKey] ?? 0) + 1;
    }
    final List<_PoolSlot> deck = deckIndices
        .map((int index) => pool[index])
        .toList(growable: false);
    final _DeckTotals totals = _deckTotals(deck, catalog, fusionOnyxSheet);
    final double totalScore = _totalByPreset(settings.focusPreset, totals);
    return DeckOptimizationResult(
      slots: List<DeckPlannedSlot>.unmodifiable(
        deck
            .map(
              (_PoolSlot s) =>
                  DeckPlannedSlot(catalogCard: s.card, entry: s.entry),
            )
            .toList(growable: false),
      ),
      totalScore: totalScore,
      soloScore: totals.attack,
      fusionScore: totals.defense,
      comboMergeScore: totals.combos.toDouble(),
      poolTruncated: false,
      consideredCount: pool.length,
      usedHeuristic: true,
    );
  }

  int? _findSeedIndex(List<_PoolSlot> pool, String? seedEntryId) {
    if (seedEntryId == null || seedEntryId.isEmpty) {
      return _indexOfStrongestDefaultSeed(pool);
    }
    final List<int> candidates = <int>[];
    for (int i = 0; i < pool.length; i++) {
      if (pool[i].entry.entryId == seedEntryId) {
        candidates.add(i);
      }
    }
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((int a, int b) {
      final int byLevel = pool[b].entry.level.compareTo(pool[a].entry.level);
      if (byLevel != 0) {
        return byLevel;
      }
      return _comparePoolIndexExcelThenEntry(pool, a, b);
    });
    return candidates.first;
  }

  /// Without an explicit seed, start from the highest instance tier so the build
  /// is not anchored to Excel order on a weak bronze/silver.
  static int? _indexOfStrongestDefaultSeed(List<_PoolSlot> pool) {
    if (pool.isEmpty) {
      return null;
    }
    int best = 0;
    ComboTier bestTier = pool[0].entry.tier;
    for (int i = 1; i < pool.length; i++) {
      final ComboTier t = pool[i].entry.tier;
      if (t.sortIndex > bestTier.sortIndex) {
        bestTier = t;
        best = i;
      } else if (t.sortIndex == bestTier.sortIndex) {
        if (_comparePoolIndexExcelThenEntry(pool, i, best) < 0) {
          best = i;
        }
      }
    }
    return best;
  }

  _PickScore _candidateScore({
    required int candidateIndex,
    required List<int> deckIndices,
    required List<_PoolSlot> pool,
    required Map<String, AlchemyCard> catalog,
    required DeckSettings settings,
    required FusionOnyxSheet? fusionOnyxSheet,
  }) {
    double attackDelta = 0;
    double defenseDelta = 0;
    int combosDelta = 0;
    double maxComboAttack = 0;
    double maxComboDefense = 0;
    double comboStatsDelta = 0;
    final _PoolSlot candidate = pool[candidateIndex];
    final double handTierLine = _handTierLineScore(
      candidate.entry.tier,
      settings.deckSize,
    );
    for (final int deckIndex in deckIndices) {
      final _PoolSlot existing = pool[deckIndex];
      final _PairOutcome outcome = _pairOutcome(
        candidate,
        existing,
        catalog,
        fusionOnyxSheet,
      );
      attackDelta += outcome.attack;
      defenseDelta += outcome.defense;
      if (outcome.hasCombo) {
        combosDelta++;
        if (outcome.attack > maxComboAttack) {
          maxComboAttack = outcome.attack;
        }
        if (outcome.defense > maxComboDefense) {
          maxComboDefense = outcome.defense;
        }
        comboStatsDelta += outcome.attack + outcome.defense;
      }
    }
    return _PickScore(
      attackSum: attackDelta,
      defenseSum: defenseDelta,
      combos: combosDelta,
      comboOpportunityCount: deckIndices.length,
      maxComboAttack: maxComboAttack,
      maxComboDefense: maxComboDefense,
      comboStatsSum: comboStatsDelta,
      handTierLine: handTierLine,
    );
  }

  int _comparePickScores(
    _PickScore a,
    _PickScore b,
    DeckSettings settings,
  ) {
    final double aw = _weightedCandidateScore(a, settings);
    final double bw = _weightedCandidateScore(b, settings);
    final int byWeighted = aw.compareTo(bw);
    if (byWeighted != 0) {
      return byWeighted;
    }
    final int byHandTier = a.handTierLine.compareTo(b.handTierLine);
    if (byHandTier != 0) {
      return byHandTier;
    }
    switch (settings.focusPreset) {
      case DeckFocusPreset.attack:
        return a.maxComboAttack.compareTo(b.maxComboAttack);
      case DeckFocusPreset.defense:
        return a.maxComboDefense.compareTo(b.maxComboDefense);
      case DeckFocusPreset.sumStats:
        return a.comboStatsSum.compareTo(b.comboStatsSum);
    }
  }

  double _weightedCandidateScore(_PickScore score, DeckSettings settings) {
    final double comboWeight = settings.comboVsStatsBalance.clamp(0.0, 1.0);
    final double statsWeight = 1.0 - comboWeight;
    final double statsNorm = _normalizedPrimaryMetric(score, settings.focusPreset);
    final double combosNorm = score.comboOpportunityCount <= 0
        ? 0.0
        : (score.combos / score.comboOpportunityCount).clamp(0.0, 1.0);
    final double pairBlend =
        statsNorm * statsWeight + combosNorm * comboWeight;
    final double handBlend = score.handTierLine;
    final double handW = settings.comboVsHandBalance.clamp(0.0, 1.0);
    return pairBlend * (1.0 - handW) + handBlend * handW;
  }

  double _normalizedPrimaryMetric(_PickScore score, DeckFocusPreset preset) {
    final int pairCount = score.comboOpportunityCount <= 0
        ? 1
        : score.comboOpportunityCount;
    switch (preset) {
      case DeckFocusPreset.attack:
        return (score.attackSum / (pairCount * 120.0)).clamp(0.0, 1.0);
      case DeckFocusPreset.defense:
        return (score.defenseSum / (pairCount * 120.0)).clamp(0.0, 1.0);
      case DeckFocusPreset.sumStats:
        return (score.comboStatsSum / (pairCount * 240.0)).clamp(0.0, 1.0);
    }
  }

  _DeckTotals _deckTotals(
    List<_PoolSlot> deck,
    Map<String, AlchemyCard> catalog,
    FusionOnyxSheet? fusionOnyxSheet,
  ) {
    double attack = 0;
    double defense = 0;
    int combos = 0;
    for (int i = 0; i < deck.length; i++) {
      for (int j = i + 1; j < deck.length; j++) {
        final _PairOutcome outcome = _pairOutcome(
          deck[i],
          deck[j],
          catalog,
          fusionOnyxSheet,
        );
        attack += outcome.attack;
        defense += outcome.defense;
        if (outcome.hasCombo) {
          combos++;
        }
      }
    }
    return _DeckTotals(attack: attack, defense: defense, combos: combos);
  }

  double _totalByPreset(DeckFocusPreset preset, _DeckTotals totals) {
    switch (preset) {
      case DeckFocusPreset.attack:
        return totals.attack;
      case DeckFocusPreset.defense:
        return totals.defense;
      case DeckFocusPreset.sumStats:
        return totals.attack + totals.defense;
    }
  }

  _PairOutcome _pairOutcome(
    _PoolSlot a,
    _PoolSlot b,
    Map<String, AlchemyCard> catalog,
    FusionOnyxSheet? fusionOnyxSheet,
  ) {
    final String? fusedId = ComboGraphLookup.fusionResultCardId(a.card, b.card);
    if (fusedId == null) {
      return const _PairOutcome(attack: 0, defense: 0, hasCombo: false);
    }
    final AlchemyCard? fused = catalog[fusedId];
    if (fused == null) {
      return const _PairOutcome(attack: 0, defense: 0, hasCombo: false);
    }
    double attack = fused.attack.toDouble();
    double defense = fused.defense.toDouble();
    final ComboTier resultTier = comboTierFromCatalogRarity(fused.rarity);
    final int resultLevel = ComboBattleStats.resultLevel(
      materialLevelA: a.entry.level,
      materialLevelB: b.entry.level,
      resultTier: resultTier,
    );
    final ComboTier highestMaterialTier = _maxTier(a.entry.tier, b.entry.tier);
    final ({int attack, int defense}) scaled = ComboBattleStats.scaledResultStats(
      resultBaseAttack: attack.round(),
      resultBaseDefense: defense.round(),
      resultLevel: resultLevel,
      highestMaterialTier: highestMaterialTier,
    );
    attack = scaled.attack.toDouble();
    defense = scaled.defense.toDouble();
    if (fusionOnyxSheet != null) {
      final String lookupA =
          SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(
        a.card.cardId,
      );
      final String lookupB =
          SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(
        b.card.cardId,
      );
      final int onyxCount = _onyxMaterialCount(a.entry, b.entry);
      final List<int>? ad = fusionOnyxSheet.resultAttackDefense(
        lookupA,
        lookupB,
        onyxCount,
      );
      if (ad != null && ad.length >= 2) {
        final ({int attack, int defense}) sheetScaled =
            ComboBattleStats.scaledResultStats(
              resultBaseAttack: ad[0],
              resultBaseDefense: ad[1],
              resultLevel: resultLevel,
              highestMaterialTier: highestMaterialTier,
            );
        attack = sheetScaled.attack.toDouble();
        defense = sheetScaled.defense.toDouble();
      }
    }
    return _PairOutcome(attack: attack, defense: defense, hasCombo: true);
  }

  ComboTier _maxTier(ComboTier a, ComboTier b) {
    return a.index >= b.index ? a : b;
  }

  static int _onyxMaterialCount(OwnedComboEntry a, OwnedComboEntry b) {
    int n = 0;
    if (a.tier.name == 'onyx') {
      n++;
    }
    if (b.tier.name == 'onyx') {
      n++;
    }
    return n.clamp(0, 2);
  }

  static int _comparePoolSlotsExcelThenEntry(_PoolSlot a, _PoolSlot b) {
    final String idA =
        SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(a.card.cardId);
    final String idB =
        SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(b.card.cardId);
    final int byCc = ExcelCcOrder.ccNumForOrbCardName(
      idA,
    ).compareTo(ExcelCcOrder.ccNumForOrbCardName(idB));
    if (byCc != 0) {
      return byCc;
    }
    return a.entry.entryId.compareTo(b.entry.entryId);
  }

  static int _comparePoolIndexExcelThenEntry(
    List<_PoolSlot> pool,
    int ia,
    int ib,
  ) {
    return _comparePoolSlotsExcelThenEntry(pool[ia], pool[ib]);
  }
}

class _PoolSlot {
  const _PoolSlot({required this.card, required this.entry});

  final AlchemyCard card;
  final OwnedComboEntry entry;
}

class _PairOutcome {
  const _PairOutcome({
    required this.attack,
    required this.defense,
    required this.hasCombo,
  });

  final double attack;
  final double defense;
  final bool hasCombo;
}

class _PickScore {
  const _PickScore({
    required this.attackSum,
    required this.defenseSum,
    required this.combos,
    required this.comboOpportunityCount,
    required this.maxComboAttack,
    required this.maxComboDefense,
    required this.comboStatsSum,
    required this.handTierLine,
  });

  final double attackSum;
  final double defenseSum;
  final int combos;
  final int comboOpportunityCount;
  final double maxComboAttack;
  final double maxComboDefense;
  final double comboStatsSum;
  /// Expected in-hand strength from instance tier (random [inGameHandSize] draw).
  final double handTierLine;
}

class _DeckTotals {
  const _DeckTotals({
    required this.attack,
    required this.defense,
    required this.combos,
  });

  final double attack;
  final double defense;
  final int combos;
}
