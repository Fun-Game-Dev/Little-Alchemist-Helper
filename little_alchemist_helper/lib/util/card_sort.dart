import '../models/alchemy_card.dart';
import '../models/combo_tier.dart';
import '../models/deck_result.dart';
import '../models/owned_combo_entry.dart';

/// How to order card lists in the UI.
enum CardListSortMode {
  /// By name A->Z.
  byName,

  /// By rarity first (bronze -> onyx), then by name.
  byRarity,

  /// By A+D sum from catalog (strongest first), then by name.
  byPower,
}

enum CardListSortDirection { ascending, descending }

bool cardListSortDirectionFromStorageBool(bool? raw, {required bool fallback}) {
  if (raw == null) {
    return fallback;
  }
  return raw;
}

/// Stored value for [SharedPreferences] (stable across enum reorder).
CardListSortMode cardListSortModeFromStorageIndex(int raw) {
  if (raw < 0 || raw >= CardListSortMode.values.length) {
    return CardListSortMode.byName;
  }
  return CardListSortMode.values[raw];
}

/// Rarity order used by catalog data (Common...Diamond).
int raritySortIndex(String rarity) {
  switch (rarity.trim()) {
    case 'Common':
    case 'common':
      return 0;
    case 'Uncommon':
    case 'uncommon':
      return 1;
    case 'Rare':
    case 'rare':
      return 2;
    case 'Diamond':
    case 'diamond':
      return 3;
    case 'Onyx':
    case 'onyx':
      return 4;
    default:
      return 50;
  }
}

int _compareByDisplayName(AlchemyCard a, AlchemyCard b) {
  return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
}

int _withDirection(int value, CardListSortDirection direction) {
  return direction == CardListSortDirection.ascending ? value : -value;
}

/// In-place sort (does not allocate a list copy).
void sortAlchemyCards(
  List<AlchemyCard> cards,
  CardListSortMode mode, {
  CardListSortDirection direction = CardListSortDirection.ascending,
}) {
  switch (mode) {
    case CardListSortMode.byName:
      cards.sort(
        (AlchemyCard a, AlchemyCard b) =>
            _withDirection(_compareByDisplayName(a, b), direction),
      );
      break;
    case CardListSortMode.byRarity:
      cards.sort((AlchemyCard a, AlchemyCard b) {
        final int ra = raritySortIndex(a.rarity);
        final int rb = raritySortIndex(b.rarity);
        final int c = _withDirection(ra.compareTo(rb), direction);
        if (c != 0) {
          return c;
        }
        return _withDirection(_compareByDisplayName(a, b), direction);
      });
      break;
    case CardListSortMode.byPower:
      cards.sort((AlchemyCard a, AlchemyCard b) {
        final int c = _withDirection(
          a.sumStats.compareTo(b.sumStats),
          direction,
        );
        if (c != 0) {
          return c;
        }
        return _withDirection(_compareByDisplayName(a, b), direction);
      });
      break;
  }
}

void sortDeckPlannedSlots(
  List<DeckPlannedSlot> slots,
  CardListSortMode mode, {
  CardListSortDirection direction = CardListSortDirection.ascending,
}) {
  switch (mode) {
    case CardListSortMode.byName:
      slots.sort((DeckPlannedSlot a, DeckPlannedSlot b) {
        return _withDirection(
          a.catalogCard.displayName.toLowerCase().compareTo(
            b.catalogCard.displayName.toLowerCase(),
          ),
          direction,
        );
      });
      break;
    case CardListSortMode.byRarity:
      slots.sort((DeckPlannedSlot a, DeckPlannedSlot b) {
        final int ra = a.entry.tier.sortIndex;
        final int rb = b.entry.tier.sortIndex;
        final int c = _withDirection(ra.compareTo(rb), direction);
        if (c != 0) {
          return c;
        }
        return _withDirection(
          a.catalogCard.displayName.toLowerCase().compareTo(
            b.catalogCard.displayName.toLowerCase(),
          ),
          direction,
        );
      });
      break;
    case CardListSortMode.byPower:
      slots.sort((DeckPlannedSlot a, DeckPlannedSlot b) {
        final int c = _withDirection(
          a.catalogCard.sumStats.compareTo(b.catalogCard.sumStats),
          direction,
        );
        if (c != 0) {
          return c;
        }
        return _withDirection(
          a.catalogCard.displayName.toLowerCase().compareTo(
            b.catalogCard.displayName.toLowerCase(),
          ),
          direction,
        );
      });
      break;
  }
}

/// Sorts collection instances using [catalog].
void sortOwnedComboEntries(
  List<OwnedComboEntry> entries,
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
    final int byName = _withDirection(
      na.toLowerCase().compareTo(nb.toLowerCase()),
      direction,
    );
    if (byName != 0) {
      return byName;
    }
    return a.entryId.compareTo(b.entryId);
  }

  switch (mode) {
    case CardListSortMode.byName:
      entries.sort(compareName);
      break;
    case CardListSortMode.byRarity:
      entries.sort((OwnedComboEntry a, OwnedComboEntry b) {
        final int ra = a.tier.sortIndex;
        final int rb = b.tier.sortIndex;
        final int c = _withDirection(ra.compareTo(rb), direction);
        if (c != 0) {
          return c;
        }
        return compareName(a, b);
      });
      break;
    case CardListSortMode.byPower:
      entries.sort((OwnedComboEntry a, OwnedComboEntry b) {
        final int c = _withDirection(power(a).compareTo(power(b)), direction);
        if (c != 0) {
          return c;
        }
        return compareName(a, b);
      });
      break;
  }
}
