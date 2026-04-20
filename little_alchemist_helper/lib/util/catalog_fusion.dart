import '../models/alchemy_card.dart';

/// Card IDs that participate in at least one fusion pair (outgoing or incoming edge).
Set<String> fusionParticipantCardIds(Map<String, AlchemyCard> catalog) {
  final Set<String> ids = <String>{};
  for (final MapEntry<String, AlchemyCard> e in catalog.entries) {
    if (e.value.combinations.isNotEmpty) {
      ids.add(e.key);
    }
    for (final String partnerId in e.value.combinations.keys) {
      ids.add(partnerId);
    }
  }
  return ids;
}

bool catalogCardCanFuse(Map<String, AlchemyCard> catalog, String cardId) {
  return fusionParticipantCardIds(catalog).contains(cardId);
}
