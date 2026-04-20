import 'package:flutter/foundation.dart';

import 'combo_tier.dart';
import 'deck_focus_preset.dart';

/// Auto-build parameters for the combo part of a single saved deck.
@immutable
class DeckSettings {
  const DeckSettings({
    required this.deckSize,
    required this.seedEntryId,
    required this.maxNonFusionCards,
    required this.focusPreset,
    required this.comboVsStatsBalance,
    required this.comboVsHandBalance,
    required this.rarityRules,
  });

  static const int minDeckSize = 25;
  static const int maxDeckSize = 40;
  static const int minMaxNonFusionCards = 0;
  static const int maxMaxNonFusionCards = 20;

  /// Snap [0,1] balance sliders to 0.05 steps (20 divisions).
  static double snapBalance05(double value) {
    return (value.clamp(0.0, 1.0) * 20).round() / 20;
  }

  static const DeckSettings defaults = DeckSettings(
    deckSize: 25,
    seedEntryId: null,
    maxNonFusionCards: 7,
    focusPreset: DeckFocusPreset.sumStats,
    comboVsStatsBalance: 0.35,
    comboVsHandBalance: 0.40,
    rarityRules: DeckRarityRules.defaults,
  );

  final int deckSize;
  final String? seedEntryId;
  final int maxNonFusionCards;
  final DeckFocusPreset focusPreset;
  final double comboVsStatsBalance;
  /// Weight of random-hand tier expectation vs pairwise inner score when choosing
  /// the next card (0 = only pairs/combos, 1 = only tier floor for a 5-card hand).
  final double comboVsHandBalance;
  final DeckRarityRules rarityRules;

  DeckSettings copyWith({
    int? deckSize,
    String? seedEntryId,
    bool clearSeedCardId = false,
    int? maxNonFusionCards,
    DeckFocusPreset? focusPreset,
    double? comboVsStatsBalance,
    double? comboVsHandBalance,
    DeckRarityRules? rarityRules,
  }) {
    return DeckSettings(
      deckSize: deckSize ?? this.deckSize,
      seedEntryId: clearSeedCardId ? null : (seedEntryId ?? this.seedEntryId),
      maxNonFusionCards: maxNonFusionCards ?? this.maxNonFusionCards,
      focusPreset: focusPreset ?? this.focusPreset,
      comboVsStatsBalance:
          (comboVsStatsBalance ?? this.comboVsStatsBalance).clamp(0.0, 1.0),
      comboVsHandBalance: snapBalance05(
        comboVsHandBalance ?? this.comboVsHandBalance,
      ),
      rarityRules: rarityRules ?? this.rarityRules,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'deckSize': deckSize,
      'seedEntryId': seedEntryId,
      'maxNonFusionCards': maxNonFusionCards,
      'focusPreset': focusPreset.name,
      'comboVsStatsBalance': comboVsStatsBalance,
      'comboVsHandBalance': comboVsHandBalance,
      'rarityRules': rarityRules.toJson(),
    };
  }

  static DeckSettings fromJson(Map<String, Object?> json) {
    final int rawSize =
        (json['deckSize'] as num?)?.toInt() ?? defaults.deckSize;
    final int deckSize = rawSize.clamp(minDeckSize, maxDeckSize);
    final int rawMaxNonFusion =
        (json['maxNonFusionCards'] as num?)?.toInt() ?? defaults.maxNonFusionCards;
    final int maxNonFusionCards = rawMaxNonFusion.clamp(
      minMaxNonFusionCards,
      maxMaxNonFusionCards,
    );
    final DeckFocusPreset preset = _parsePreset(json['focusPreset']);
    final double comboVsStatsBalance =
        (json['comboVsStatsBalance'] as num?)?.toDouble() ??
        defaults.comboVsStatsBalance;
    final double comboVsHandBalanceRaw =
        (json['comboVsHandBalance'] as num?)?.toDouble() ??
        defaults.comboVsHandBalance;
    final String? seedEntryId = _parseSeedEntryId(json['seedEntryId']);
    return DeckSettings(
      deckSize: deckSize,
      seedEntryId: seedEntryId,
      maxNonFusionCards: maxNonFusionCards,
      focusPreset: preset,
      comboVsStatsBalance: comboVsStatsBalance.clamp(0.0, 1.0),
      comboVsHandBalance: snapBalance05(comboVsHandBalanceRaw),
      rarityRules: DeckRarityRules.fromJson(json['rarityRules']),
    );
  }

  static String? _parseSeedEntryId(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static DeckFocusPreset _parsePreset(Object? raw) {
    if (raw is! String) {
      return defaults.focusPreset;
    }
    for (final DeckFocusPreset p in DeckFocusPreset.values) {
      if (p.name == raw) {
        return p;
      }
    }
    return defaults.focusPreset;
  }
}

@immutable
class DeckRarityRule {
  const DeckRarityRule({required this.minLevel});

  static const DeckRarityRule defaults = DeckRarityRule(minLevel: 6);

  final int minLevel;

  DeckRarityRule copyWith({int? minLevel}) {
    return DeckRarityRule(
      minLevel: minLevel ?? this.minLevel,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{'minLevel': minLevel};
  }

  static DeckRarityRule fromJson(Object? raw) {
    if (raw is! Map) {
      return defaults;
    }
    final Object? rawMin = raw['minLevel'];
    final int minLevel = (rawMin as num?)?.toInt() ?? defaults.minLevel;
    return DeckRarityRule(
      minLevel: minLevel.clamp(1, 6),
    );
  }
}

@immutable
class DeckRarityRules {
  const DeckRarityRules({
    required this.bronze,
    required this.silver,
    required this.gold,
    required this.diamond,
    required this.onyx,
  });

  static const DeckRarityRules defaults = DeckRarityRules(
    bronze: DeckRarityRule.defaults,
    silver: DeckRarityRule.defaults,
    gold: DeckRarityRule.defaults,
    diamond: DeckRarityRule.defaults,
    onyx: DeckRarityRule.defaults,
  );

  final DeckRarityRule bronze;
  final DeckRarityRule silver;
  final DeckRarityRule gold;
  final DeckRarityRule diamond;
  final DeckRarityRule onyx;

  DeckRarityRule ruleFor(ComboTier tier) {
    switch (tier) {
      case ComboTier.bronze:
        return bronze;
      case ComboTier.silver:
        return silver;
      case ComboTier.gold:
        return gold;
      case ComboTier.diamond:
        return diamond;
      case ComboTier.onyx:
        return onyx;
    }
  }

  DeckRarityRules copyWithTier(ComboTier tier, DeckRarityRule value) {
    switch (tier) {
      case ComboTier.bronze:
        return DeckRarityRules(
          bronze: value,
          silver: silver,
          gold: gold,
          diamond: diamond,
          onyx: onyx,
        );
      case ComboTier.silver:
        return DeckRarityRules(
          bronze: bronze,
          silver: value,
          gold: gold,
          diamond: diamond,
          onyx: onyx,
        );
      case ComboTier.gold:
        return DeckRarityRules(
          bronze: bronze,
          silver: silver,
          gold: value,
          diamond: diamond,
          onyx: onyx,
        );
      case ComboTier.diamond:
        return DeckRarityRules(
          bronze: bronze,
          silver: silver,
          gold: gold,
          diamond: value,
          onyx: onyx,
        );
      case ComboTier.onyx:
        return DeckRarityRules(
          bronze: bronze,
          silver: silver,
          gold: gold,
          diamond: diamond,
          onyx: value,
        );
    }
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'bronze': bronze.toJson(),
      'silver': silver.toJson(),
      'gold': gold.toJson(),
      'diamond': diamond.toJson(),
      'onyx': onyx.toJson(),
    };
  }

  static DeckRarityRules fromJson(Object? raw) {
    if (raw is! Map) {
      return defaults;
    }
    return DeckRarityRules(
      bronze: DeckRarityRule.fromJson(raw['bronze']),
      silver: DeckRarityRule.fromJson(raw['silver']),
      gold: DeckRarityRule.fromJson(raw['gold']),
      diamond: DeckRarityRule.fromJson(raw['diamond']),
      onyx: DeckRarityRule.fromJson(raw['onyx']),
    );
  }
}
