import 'package:flutter/foundation.dart';

/// Card from [AlchemyCardData.json]; [cardId] is the top-level JSON key.
@immutable
class AlchemyCard {
  const AlchemyCard({
    required this.cardId,
    required this.displayName,
    required this.attack,
    required this.defense,
    required this.rarity,
    required this.fusionAbility,
    required this.pictureKey,
    required this.cardNum,
    required this.description,
    required this.combinations,
    required this.isLte,
    required this.seasonalTag,
  });

  final String cardId;
  final String displayName;
  final int attack;
  final int defense;
  final String rarity;
  final String fusionAbility;
  final String pictureKey;
  final String cardNum;
  final String description;
  final Map<String, String> combinations;
  final bool isLte;
  final String? seasonalTag;

  int get sumStats => attack + defense;

  /// Whether outgoing recipes exist in [combinations].
  ///
  /// To include cards that appear only as partner entries of other cards,
  /// use [catalogCardCanFuse] / [fusionParticipantCardIds].
  bool get isComboMaterial => combinations.isNotEmpty;

  AlchemyCard copyWith({
    String? cardId,
    String? displayName,
    int? attack,
    int? defense,
    String? rarity,
    String? fusionAbility,
    String? pictureKey,
    String? cardNum,
    String? description,
    Map<String, String>? combinations,
    bool? isLte,
    String? seasonalTag,
  }) {
    return AlchemyCard(
      cardId: cardId ?? this.cardId,
      displayName: displayName ?? this.displayName,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      rarity: rarity ?? this.rarity,
      fusionAbility: fusionAbility ?? this.fusionAbility,
      pictureKey: pictureKey ?? this.pictureKey,
      cardNum: cardNum ?? this.cardNum,
      description: description ?? this.description,
      combinations: combinations ?? this.combinations,
      isLte: isLte ?? this.isLte,
      seasonalTag: seasonalTag ?? this.seasonalTag,
    );
  }

  /// Variant with `Fused ` prefix in display name (separate collection entity).
  bool get isFusedVariant {
    final String n = displayName.trim();
    return n.length > 6 && n.substring(0, 6).toLowerCase() == 'fused ';
  }

  /// Deck-limit key: one logical name for bronze/onyx/fused variants, without `Fused ` prefix.
  String get deckGroupKey {
    String n = displayName.trim();
    if (n.length > 6 && n.substring(0, 6).toLowerCase() == 'fused ') {
      n = n.substring(6).trim();
    }
    if (n.isEmpty) {
      return cardId.toLowerCase();
    }
    return n.toLowerCase();
  }
}
