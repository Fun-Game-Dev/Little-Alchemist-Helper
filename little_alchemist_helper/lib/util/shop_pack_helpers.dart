import '../models/alchemy_card.dart';

/// Case-insensitive match on [AlchemyCard.displayName].
AlchemyCard? catalogCardByDisplayName(
  Map<String, AlchemyCard> catalog,
  String displayName,
) {
  final String t = displayName.trim().toLowerCase();
  if (t.isEmpty) {
    return null;
  }
  for (final AlchemyCard c in catalog.values) {
    if (c.displayName.trim().toLowerCase() == t) {
      return c;
    }
  }
  return null;
}
