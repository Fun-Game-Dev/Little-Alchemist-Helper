import '../models/alchemy_card.dart';

/// Looks up fusion result for two cards using catalog data.
class ComboGraphLookup {
  const ComboGraphLookup._();

  /// Result [cardId], or null if the pair does not exist in data.
  static String? fusionResultCardId(AlchemyCard a, AlchemyCard b) {
    final String? r1 = a.combinations[b.cardId];
    if (r1 != null && r1.isNotEmpty) {
      return r1;
    }
    final String? r2 = b.combinations[a.cardId];
    if (r2 != null && r2.isNotEmpty) {
      return r2;
    }
    return null;
  }
}
