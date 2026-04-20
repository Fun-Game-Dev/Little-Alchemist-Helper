part of 'app_controller.dart';

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, unused_element

extension AppControllerPreferencesExtension on AppController {
  void setComboLabPickA(ComboLabMaterialPick? value) {
    _comboLabPickA = value;
    notifyListeners();
  }

  void setComboLabPickB(ComboLabMaterialPick? value) {
    _comboLabPickB = value;
    notifyListeners();
  }

  Future<void> setUiCardListSortMode(CardListSortMode mode) async {
    _uiCardListSortMode = mode;
    await _store.writeUiCardListSortMode(mode);
    notifyListeners();
  }

  Future<void> setUiCardListSortDirection(
    CardListSortDirection direction,
  ) async {
    _uiCardListSortDirection = direction;
    await _store.writeUiCardListSortDirection(direction);
    notifyListeners();
  }

  Future<void> setUiCollapseDuplicates(bool value) async {
    _uiCollapseDuplicates = value;
    await _store.writeUiCollapseDuplicates(value);
    notifyListeners();
  }

  Future<void> setUiCatalogPresenceFilter(CatalogOwnedPresenceFilter f) async {
    _uiCatalogPresenceFilter = f;
    await _store.writeUiCatalogPresenceFilter(f);
    notifyListeners();
  }

  Future<void> setUiCatalogRarityTierFilter(ComboTier? tier) async {
    _uiCatalogRarityTierFilter = tier;
    await _store.writeUiCatalogRarityTierFilter(tier);
    notifyListeners();
  }

  Future<void> setUiCatalogListSortMode(CardListSortMode mode) async {
    _uiCatalogListSortMode = mode;
    await _store.writeUiCatalogListSortMode(mode);
    notifyListeners();
  }

  Future<void> setUiCatalogListSortDirection(
    CardListSortDirection direction,
  ) async {
    _uiCatalogListSortDirection = direction;
    await _store.writeUiCatalogListSortDirection(direction);
    notifyListeners();
  }

  Future<void> persistLastComboLevel(int level) async {
    final int lvl = level.clamp(
      OwnedComboEntry.minLevel,
      OwnedComboEntry.maxLevel,
    );
    _lastAddComboLevel = lvl;
    await _store.writeLastAddComboLevel(lvl);
    notifyListeners();
  }

  Future<void> persistAddOneSheetDraft({
    required String searchQuery,
    String? selectedCardId,
    required double listScrollOffset,
  }) async {
    final String trimmed = searchQuery.trim();
    _uiAddOneSheetSearchQuery = trimmed.isEmpty ? null : trimmed;
    _uiAddOneSheetSelectedCardId = selectedCardId;
    _uiAddOneSheetListScrollOffset = listScrollOffset.clamp(0.0, 1e7);
    await _store.writeAddOneSheetSearchQuery(_uiAddOneSheetSearchQuery);
    await _store.writeAddOneSheetSelectedCardId(selectedCardId);
    await _store.writeAddOneSheetListScrollOffset(
      _uiAddOneSheetListScrollOffset,
    );
    notifyListeners();
  }

  Future<void> _hydratePrefsOnly() async {
    _loadCardImages = _store.readLoadCardImages();
    _lastAddComboLevel = _store.readLastAddComboLevel();
    _uiCardListSortMode = _store.readUiCardListSortMode();
    _uiCardListSortDirection = _store.readUiCardListSortDirection();
    _uiCollapseDuplicates = _store.readUiCollapseDuplicates();
    _uiCatalogPresenceFilter = _store.readUiCatalogPresenceFilter();
    _uiCatalogRarityTierFilter = _store.readUiCatalogRarityTierFilter();
    _uiCatalogListSortMode = _store.readUiCatalogListSortMode();
    _uiCatalogListSortDirection = _store.readUiCatalogListSortDirection();
    _uiAddOneSheetSearchQuery = _store.readAddOneSheetSearchQuery();
    _uiAddOneSheetSelectedCardId = _store.readAddOneSheetSelectedCardId();
    _uiAddOneSheetListScrollOffset = _store.readAddOneSheetListScrollOffset();
    _augmentSyntheticOnyxCatalog = _store.readAugmentSyntheticOnyxCatalog();
    _userCatalogOverlayPath = _store.readUserCatalogOverlayPath();
  }

  Future<void> setLoadCardImages(bool value) async {
    _loadCardImages = value;
    await _store.writeLoadCardImages(value);
    notifyListeners();
  }

  Future<void> setAugmentSyntheticOnyxCatalog(bool value) async {
    _augmentSyntheticOnyxCatalog = value;
    await _store.writeAugmentSyntheticOnyxCatalog(value);
    await _loadMergedCatalog(
      userOverlayPath: _userCatalogOverlayPath,
      inlineUserOverlayJson: null,
      bundledMessage: (int n) => value
          ? _l10n.loadSyntheticOnyxEnabled(n)
          : _l10n.loadSyntheticOnyxDisabled(n),
    );
  }
}
