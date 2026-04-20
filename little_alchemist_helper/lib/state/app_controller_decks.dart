part of 'app_controller.dart';

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, unused_element

extension AppControllerDecksExtension on AppController {
  Future<void> _hydrateDecksOnly() async {
    _deckProfiles = List<DeckProfile>.from(_store.readDeckProfiles());
    if (_deckProfiles.isEmpty) {
      final DeckProfile first = DeckProfile(
        id: CollectionStore.createEntryId(),
        name: _l10n.deckDefaultName(1),
        settings: DeckSettings.defaults,
      );
      _deckProfiles = <DeckProfile>[first];
      final bool saved = await _store.writeDeckProfiles(_deckProfiles);
      if (!saved) {
        _loadMessage = _l10n.loadSaveDecksStorageFailed;
        notifyListeners();
      }
      _selectedDeckId = first.id;
      await _store.writeSelectedDeckId(_selectedDeckId);
    } else {
      _selectedDeckId = _store.readSelectedDeckId();
      if (_selectedDeckId == null ||
          !_deckProfiles.any((DeckProfile p) => p.id == _selectedDeckId)) {
        _selectedDeckId = _deckProfiles.first.id;
        await _store.writeSelectedDeckId(_selectedDeckId);
      }
    }
  }

  Future<void> selectDeck(String deckId) async {
    if (!_deckProfiles.any((DeckProfile p) => p.id == deckId)) {
      return;
    }
    _selectedDeckId = deckId;
    await _store.writeSelectedDeckId(deckId);
    notifyListeners();
    recomputeBestDeck();
  }

  Future<bool> addDeckProfile({String? name}) async {
    final DeckProfile p = DeckProfile(
      id: CollectionStore.createEntryId(),
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : _l10n.deckDefaultName(_deckProfiles.length + 1),
      settings: DeckSettings.defaults,
    );
    final List<DeckProfile> previous = List<DeckProfile>.from(_deckProfiles);
    _deckProfiles = List<DeckProfile>.from(_deckProfiles)..add(p);
    final bool ok = await _store.writeDeckProfiles(_deckProfiles);
    if (!ok) {
      _deckProfiles = previous;
      _loadMessage = _l10n.loadCouldNotSaveDecks;
      notifyListeners();
      return false;
    }
    _selectedDeckId = p.id;
    await _store.writeSelectedDeckId(p.id);
    notifyListeners();
    recomputeBestDeck();
    return true;
  }

  Future<bool> updateDeckProfile(DeckProfile profile) async {
    final List<DeckProfile> next = <DeckProfile>[];
    bool found = false;
    for (final DeckProfile p in _deckProfiles) {
      if (p.id == profile.id) {
        next.add(profile);
        found = true;
      } else {
        next.add(p);
      }
    }
    if (!found) {
      return false;
    }
    final List<DeckProfile> previous = List<DeckProfile>.from(_deckProfiles);
    _deckProfiles = next;
    final bool ok = await _store.writeDeckProfiles(_deckProfiles);
    if (!ok) {
      _deckProfiles = previous;
      _loadMessage = _l10n.loadCouldNotSaveDecks;
      notifyListeners();
      return false;
    }
    notifyListeners();
    recomputeBestDeck();
    return true;
  }

  Future<bool> removeDeckProfile(String deckId) async {
    if (_deckProfiles.length <= 1) {
      return false;
    }
    final List<DeckProfile> previous = List<DeckProfile>.from(_deckProfiles);
    _deckProfiles = _deckProfiles
        .where((DeckProfile p) => p.id != deckId)
        .toList();
    final bool ok = await _store.writeDeckProfiles(_deckProfiles);
    if (!ok) {
      _deckProfiles = previous;
      _loadMessage = _l10n.loadCouldNotSaveDecks;
      notifyListeners();
      return false;
    }
    if (_selectedDeckId == deckId) {
      _selectedDeckId = _deckProfiles.first.id;
      await _store.writeSelectedDeckId(_selectedDeckId);
    }
    notifyListeners();
    recomputeBestDeck();
    return true;
  }

  void recomputeBestDeck() {
    final DeckProfile? profile = selectedDeckProfile;
    if (profile == null) {
      return;
    }
    final DeckOptimizationResult? r = _optimizer.optimize(
      catalog: _catalog,
      ownedComboEntries: _ownedComboEntries,
      settings: profile.settings,
      fusionOnyxSheet: _fusionOnyxSheet,
    );
    _lastDeckResult = r;
    notifyListeners();
    if (r != null && _loadCardImages) {
      prefetchWikiImagesForCards(
        r.slots.map((DeckPlannedSlot s) => s.catalogCard),
      );
    }
  }
}
