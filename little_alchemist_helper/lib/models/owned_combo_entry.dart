import 'package:flutter/foundation.dart';

import 'combo_tier.dart';

/// One physical combo-card instance: level 1-5, or **fused** as level 6.
@immutable
class OwnedComboEntry {
  const OwnedComboEntry({
    required this.entryId,
    required this.cardId,
    required this.tier,
    required this.level,
  });

  final String entryId;
  final String cardId;
  final ComboTier tier;

  /// 1-5 are regular levels; [fusedLevel] is the fused variant (as in game after two 5-star cards).
  final int level;

  static const int minLevel = 1;
  static const int maxLevel = 6;
  static const int fusedLevel = 6;

  bool get isFused => level >= fusedLevel;

  /// Fusion score for a pair of instances (regular contributes 1, fused 2; capped at 3).
  static int pairMergeComboPointValue({
    required bool aFused,
    required bool bFused,
  }) {
    final int a = aFused ? 2 : 1;
    final int b = bFused ? 2 : 1;
    final int sum = a + b;
    return sum > 3 ? 3 : sum;
  }

  OwnedComboEntry copyWith({
    String? entryId,
    String? cardId,
    ComboTier? tier,
    int? level,
  }) {
    return OwnedComboEntry(
      entryId: entryId ?? this.entryId,
      cardId: cardId ?? this.cardId,
      tier: tier ?? this.tier,
      level: level ?? this.level,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'entryId': entryId,
      'cardId': cardId,
      'tier': tier.nameForStorage,
      'level': level,
    };
  }

  static OwnedComboEntry? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final String? id = json['entryId'] as String?;
    final String? cid = json['cardId'] as String?;
    if (id == null || id.isEmpty || cid == null || cid.isEmpty) {
      return null;
    }
    final String? tierRaw = json['tier'] as String?;
    final ComboTier? tierParsed = tierRaw != null
        ? comboTierFromStorageName(tierRaw)
        : null;
    final bool legacyFused = json['fused'] as bool? ?? false;
    int lvl = (json['level'] as num?)?.toInt() ?? minLevel;
    if (legacyFused) {
      lvl = fusedLevel;
    } else {
      lvl = lvl.clamp(minLevel, maxLevel);
    }
    return OwnedComboEntry(
      entryId: id,
      cardId: cid,
      tier: tierParsed ?? ComboTier.bronze,
      level: lvl,
    );
  }
}
