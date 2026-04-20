part of 'app_controller.dart';

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, unused_element

extension AppControllerCollectionExtension on AppController {
  int _collectionCountForDeckGroup(String deckGroupKey) {
    int n = 0;
    for (final OwnedComboEntry e in _ownedComboEntries) {
      final AlchemyCard? c = _catalog[e.cardId];
      if (c != null && c.deckGroupKey == deckGroupKey) {
        n++;
      }
    }
    return n;
  }

  Future<void> bulkAddOwnedComboEntries({
    required List<String> cardIds,
    required int copiesPerCard,
    required int level,
    ComboTier? instanceTierOverride,
    bool allowExcessPerDeckGroup = false,
  }) async {
    final int copies = copiesPerCard.clamp(1, 99);
    final int lvl = level.clamp(
      OwnedComboEntry.minLevel,
      OwnedComboEntry.maxLevel,
    );
    final List<OwnedComboEntry> add = <OwnedComboEntry>[];
    final Map<String, int> pendingByDeckGroup = <String, int>{};
    for (final String id in cardIds) {
      final AlchemyCard? c = _catalog[id];
      if (c == null || !cardCanFuse(id)) {
        continue;
      }
      final ComboTier catalogTier = comboTierFromCatalogRarity(c.rarity);
      final ComboTier tierBase = instanceTierOverride ?? catalogTier;
      final ComboTier tierForCard = clampInstanceTierToCatalog(c, tierBase);
      for (int i = 0; i < copies; i++) {
        if (!allowExcessPerDeckGroup) {
          final String g = c.deckGroupKey;
          final int existing = _collectionCountForDeckGroup(g);
          final int pending = pendingByDeckGroup[g] ?? 0;
          if (existing + pending >= CollectionStore.maxCopiesPerDeckGroupName) {
            break;
          }
          pendingByDeckGroup[g] = pending + 1;
        }
        add.add(
          OwnedComboEntry(
            entryId: CollectionStore.createEntryId(),
            cardId: id,
            tier: tierForCard,
            level: lvl,
          ),
        );
      }
    }
    if (add.isEmpty) {
      return;
    }
    _ownedComboEntries = List<OwnedComboEntry>.from(_ownedComboEntries)
      ..addAll(add);
    await _saveOwnedEntries();
    _lastDeckResult = null;
    notifyListeners();
  }

  Future<void> addOwnedComboEntry({
    required String cardId,
    required ComboTier tier,
    required int level,
  }) async {
    final AlchemyCard? c = _catalog[cardId];
    if (c == null || !cardCanFuse(cardId)) {
      return;
    }
    final ComboTier tierSafe = clampInstanceTierToCatalog(c, tier);
    final int lvl = level.clamp(OwnedComboEntry.minLevel, OwnedComboEntry.maxLevel);
    final OwnedComboEntry e = OwnedComboEntry(
      entryId: CollectionStore.createEntryId(),
      cardId: cardId,
      tier: tierSafe,
      level: lvl,
    );
    _ownedComboEntries = List<OwnedComboEntry>.from(_ownedComboEntries)..add(e);
    _lastAddComboLevel = lvl;
    await _store.writeLastAddComboLevel(lvl);
    await _saveOwnedEntries();
    _lastDeckResult = null;
    notifyListeners();
  }

  Future<void> removeOwnedEntry(String entryId) async {
    _ownedComboEntries = _ownedComboEntries
        .where((OwnedComboEntry e) => e.entryId != entryId)
        .toList();
    await _saveOwnedEntries();
    _lastDeckResult = null;
    notifyListeners();
  }

  Future<void> updateOwnedEntry(OwnedComboEntry updated) async {
    final AlchemyCard? c = _catalog[updated.cardId];
    if (c == null || !cardCanFuse(updated.cardId)) {
      return;
    }
    final List<OwnedComboEntry> next = <OwnedComboEntry>[];
    bool found = false;
    for (final OwnedComboEntry e in _ownedComboEntries) {
      if (e.entryId == updated.entryId) {
        next.add(
          updated.copyWith(
            tier: clampInstanceTierToCatalog(c, updated.tier),
            level: updated.level.clamp(
              OwnedComboEntry.minLevel,
              OwnedComboEntry.maxLevel,
            ),
          ),
        );
        found = true;
      } else {
        next.add(e);
      }
    }
    if (!found) {
      return;
    }
    _ownedComboEntries = next;
    await _saveOwnedEntries();
    _lastDeckResult = null;
    notifyListeners();
  }

  Future<void> clearCollection() async {
    _ownedComboEntries = <OwnedComboEntry>[];
    await _saveOwnedEntries();
    _lastDeckResult = null;
    notifyListeners();
  }
}
