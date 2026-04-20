import '../models/alchemy_card.dart';
import '../models/combo_tier.dart';
import '../models/deck_result.dart';
import '../models/owned_combo_entry.dart';
import 'card_sort.dart';

/// Group of identical collection instances (same cardId, tier, and level).
class OwnedComboEntryGroup {
  const OwnedComboEntryGroup({required this.entries});

  final List<OwnedComboEntry> entries;

  OwnedComboEntry get representative => entries.first;

  int get count => entries.length;
}

/// Group of identical slots in an optimized deck.
class DeckPlannedSlotGroup {
  const DeckPlannedSlotGroup({required this.slots});

  final List<DeckPlannedSlot> slots;

  DeckPlannedSlot get representative => slots.first;

  int get count => slots.length;
}

String _ownedGroupKey(OwnedComboEntry e) {
  return '${e.cardId}|${e.tier.nameForStorage}|${e.level}';
}

/// Splits list into groups with matching [cardId], [ComboTier], and level.
List<OwnedComboEntryGroup> groupOwnedComboEntries(
  List<OwnedComboEntry> entries,
) {
  final Map<String, List<OwnedComboEntry>> byKey =
      <String, List<OwnedComboEntry>>{};
  for (final OwnedComboEntry e in entries) {
    final String k = _ownedGroupKey(e);
    byKey.putIfAbsent(k, () => <OwnedComboEntry>[]).add(e);
  }
  return byKey.values
      .map((List<OwnedComboEntry> list) => OwnedComboEntryGroup(entries: list))
      .toList(growable: false);
}

String _deckSlotGroupKey(DeckPlannedSlot s) {
  final OwnedComboEntry e = s.entry;
  return '${e.cardId}|${e.tier.nameForStorage}|${e.level}';
}

List<DeckPlannedSlotGroup> groupDeckPlannedSlots(List<DeckPlannedSlot> slots) {
  final Map<String, List<DeckPlannedSlot>> byKey =
      <String, List<DeckPlannedSlot>>{};
  for (final DeckPlannedSlot s in slots) {
    final String k = _deckSlotGroupKey(s);
    byKey.putIfAbsent(k, () => <DeckPlannedSlot>[]).add(s);
  }
  return byKey.values
      .map((List<DeckPlannedSlot> list) => DeckPlannedSlotGroup(slots: list))
      .toList(growable: false);
}

void sortOwnedComboEntryGroups(
  List<OwnedComboEntryGroup> groups,
  CardListSortMode mode,
  Map<String, AlchemyCard> catalog, {
  CardListSortDirection direction = CardListSortDirection.ascending,
}) {
  int power(OwnedComboEntry e) {
    final AlchemyCard? c = catalog[e.cardId];
    return c?.sumStats ?? 0;
  }

  int compareName(OwnedComboEntry a, OwnedComboEntry b) {
    final AlchemyCard? ca = catalog[a.cardId];
    final AlchemyCard? cb = catalog[b.cardId];
    final String na = ca?.displayName ?? a.cardId;
    final String nb = cb?.displayName ?? b.cardId;
    final int byName = direction == CardListSortDirection.ascending
        ? na.toLowerCase().compareTo(nb.toLowerCase())
        : nb.toLowerCase().compareTo(na.toLowerCase());
    if (byName != 0) {
      return byName;
    }
    return a.entryId.compareTo(b.entryId);
  }

  switch (mode) {
    case CardListSortMode.byName:
      groups.sort(
        (OwnedComboEntryGroup ga, OwnedComboEntryGroup gb) =>
            compareName(ga.representative, gb.representative),
      );
      break;
    case CardListSortMode.byRarity:
      groups.sort((OwnedComboEntryGroup ga, OwnedComboEntryGroup gb) {
        final int ra = ga.representative.tier.sortIndex;
        final int rb = gb.representative.tier.sortIndex;
        final int c = direction == CardListSortDirection.ascending
            ? ra.compareTo(rb)
            : rb.compareTo(ra);
        if (c != 0) {
          return c;
        }
        return compareName(ga.representative, gb.representative);
      });
      break;
    case CardListSortMode.byPower:
      groups.sort((OwnedComboEntryGroup ga, OwnedComboEntryGroup gb) {
        final int c = direction == CardListSortDirection.ascending
            ? power(ga.representative).compareTo(power(gb.representative))
            : power(gb.representative).compareTo(power(ga.representative));
        if (c != 0) {
          return c;
        }
        return compareName(ga.representative, gb.representative);
      });
      break;
  }
}

void sortDeckPlannedSlotGroups(
  List<DeckPlannedSlotGroup> groups,
  CardListSortMode mode, {
  CardListSortDirection direction = CardListSortDirection.ascending,
}) {
  switch (mode) {
    case CardListSortMode.byName:
      groups.sort((DeckPlannedSlotGroup ga, DeckPlannedSlotGroup gb) {
        final String a = ga.representative.catalogCard.displayName
            .toLowerCase();
        final String b = gb.representative.catalogCard.displayName
            .toLowerCase();
        return direction == CardListSortDirection.ascending
            ? a.compareTo(b)
            : b.compareTo(a);
      });
      break;
    case CardListSortMode.byRarity:
      groups.sort((DeckPlannedSlotGroup ga, DeckPlannedSlotGroup gb) {
        final int ra = ga.representative.entry.tier.sortIndex;
        final int rb = gb.representative.entry.tier.sortIndex;
        final int c = direction == CardListSortDirection.ascending
            ? ra.compareTo(rb)
            : rb.compareTo(ra);
        if (c != 0) {
          return c;
        }
        final String a = ga.representative.catalogCard.displayName
            .toLowerCase();
        final String b = gb.representative.catalogCard.displayName
            .toLowerCase();
        return direction == CardListSortDirection.ascending
            ? a.compareTo(b)
            : b.compareTo(a);
      });
      break;
    case CardListSortMode.byPower:
      groups.sort((DeckPlannedSlotGroup ga, DeckPlannedSlotGroup gb) {
        final int c = direction == CardListSortDirection.ascending
            ? ga.representative.catalogCard.sumStats.compareTo(
                gb.representative.catalogCard.sumStats,
              )
            : gb.representative.catalogCard.sumStats.compareTo(
                ga.representative.catalogCard.sumStats,
              );
        if (c != 0) {
          return c;
        }
        final String a = ga.representative.catalogCard.displayName
            .toLowerCase();
        final String b = gb.representative.catalogCard.displayName
            .toLowerCase();
        return direction == CardListSortDirection.ascending
            ? a.compareTo(b)
            : b.compareTo(a);
      });
      break;
  }
}
