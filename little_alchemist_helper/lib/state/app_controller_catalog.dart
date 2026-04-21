part of 'app_controller.dart';

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, unused_element

extension AppControllerCatalogExtension on AppController {
  static const String noAbilityKey = '__no_ability__';

  Future<void> _yieldToUiThread() async {
    await Future<void>.delayed(Duration.zero);
  }

  Map<ComboTier, int> get catalogRarityCounts {
    final Map<ComboTier, int> counts = <ComboTier, int>{
      ComboTier.bronze: 0,
      ComboTier.silver: 0,
      ComboTier.gold: 0,
      ComboTier.diamond: 0,
      ComboTier.onyx: 0,
    };
    for (final AlchemyCard card in _catalog.values) {
      final ComboTier tier = comboTierFromCatalogRarity(card.rarity);
      counts[tier] = (counts[tier] ?? 0) + 1;
    }
    return Map<ComboTier, int>.unmodifiable(counts);
  }

  int get catalogCount => _catalog.length;

  Map<String, Map<ComboTier, int>> get catalogAbilityRarityCounts {
    final Map<String, Map<ComboTier, int>> counts =
        <String, Map<ComboTier, int>>{};
    for (final AlchemyCard card in _catalog.values) {
      final String rawAbility = card.fusionAbility.trim();
      final String ability = rawAbility.isEmpty ? noAbilityKey : rawAbility;
      final ComboTier tier = comboTierFromCatalogRarity(card.rarity);
      final Map<ComboTier, int> byTier =
          counts.putIfAbsent(ability, () => <ComboTier, int>{});
      byTier[tier] = (byTier[tier] ?? 0) + 1;
    }
    return Map<String, Map<ComboTier, int>>.unmodifiable(
      counts.map(
        (String ability, Map<ComboTier, int> byTier) => MapEntry<
            String,
            Map<ComboTier, int>>(
          ability,
          Map<ComboTier, int>.unmodifiable(byTier),
        ),
      ),
    );
  }

  bool cardCanFuse(String cardId) => _fusionParticipantIds.contains(cardId);

  bool catalogCardIdInCollection(String cardId) {
    for (final OwnedComboEntry e in _ownedComboEntries) {
      if (e.cardId == cardId) {
        return true;
      }
    }
    return false;
  }

  int get totalComboCopies => _ownedComboEntries.length;

  int get comboKindsOwned {
    final Set<String> ids = <String>{};
    for (final OwnedComboEntry e in _ownedComboEntries) {
      ids.add(e.cardId);
    }
    return ids.length;
  }

  Map<String, int> get collectionGroupCountsOverLimit {
    final Map<String, int> byGroup = <String, int>{};
    for (final OwnedComboEntry e in _ownedComboEntries) {
      final AlchemyCard? c = _catalog[e.cardId];
      if (c == null) {
        continue;
      }
      final String g = c.deckGroupKey;
      byGroup[g] = (byGroup[g] ?? 0) + 1;
    }
    final Map<String, int> bad = <String, int>{};
    byGroup.forEach((String g, int n) {
      if (n > CollectionStore.maxCopiesPerDeckGroupName) {
        bad[g] = n;
      }
    });
    return Map<String, int>.unmodifiable(bad);
  }

  Future<void> _loadFusionOnyxSheet() async {
    try {
      final String raw = await rootBundle.loadString(
        'assets/fusion_onyx_stats.json',
      );
      _fusionOnyxSheet = FusionOnyxSheet.parse(raw);
    } on Object catch (_) {
      _fusionOnyxSheet = null;
    }
  }

  Future<void> _hydrateOwnedFromStore() async {
    _ownedComboEntries = _sanitizeEntries(
      _store.readOwnedComboEntries(catalog: _catalog),
    );
    await _saveOwnedEntries();
  }

  Future<void> _saveOwnedEntries() async {
    await _store.writeOwnedComboEntries(_ownedComboEntries);
  }

  Future<void> _loadInitialCatalog({
    void Function(String message, double progress)? onProgress,
  }) async {
    await _loadMergedCatalog(
      userOverlayPath: _userCatalogOverlayPath,
      inlineUserOverlayJson: null,
      bundledMessage: (int n) => _l10n.loadCatalogLoaded(n),
      onProgress: onProgress,
    );
  }

  Future<String> _loadBundledCombinationPatchJson() async {
    try {
      return await rootBundle.loadString('assets/CombinationPatch.json');
    } on Object catch (_) {
      return '';
    }
  }

  Future<void> _loadMergedCatalog({
    required String? userOverlayPath,
    required String? inlineUserOverlayJson,
    required String Function(int cardCount) bundledMessage,
    void Function(String message, double progress)? onProgress,
  }) async {
    void report(String message, double progress) {
      onProgress?.call(message, progress.clamp(0.0, 1.0));
    }

    _loadMessage = null;
    try {
      report(_l10n.catalogProgressLoadOnyxSheet, 0.05);
      await _loadFusionOnyxSheet();
      await _yieldToUiThread();
      report(_l10n.catalogProgressReadBaseCatalog, 0.12);
      final String alchemyRaw = await rootBundle.loadString(
        'assets/AlchemyCardData.json',
      );
      final Object? alchemyDecoded = jsonDecode(alchemyRaw);
      if (alchemyDecoded is! Map) {
        throw const FormatException('AlchemyCardData.json: object expected');
      }
      final Map<String, Object?> root = jsonMapToStringKeyed(alchemyDecoded);
      await _yieldToUiThread();
      report(_l10n.catalogProgressMergeExcel, 0.22);
      final String excelRaw = await rootBundle.loadString(
        'assets/data_from_exel.txt',
      );
      final Map<String, Object?> excelRoot = ExcelComboBaseBuilder.buildRootMap(
        excelRaw,
      );
      mergeExcelSupplementIntoRoot(root, excelRoot);
      await _yieldToUiThread();
      report(_l10n.catalogProgressApplyComboPatch, 0.32);
      final String comboRaw = await _loadBundledCombinationPatchJson();
      final String trimmedCombo = comboRaw.trim();
      if (trimmedCombo.isNotEmpty && trimmedCombo != '{}') {
        final Object? comboDecoded = jsonDecode(comboRaw);
        if (comboDecoded is Map) {
          mergeCombinationPatchIntoRoot(
            root,
            jsonMapToStringKeyed(comboDecoded),
          );
        }
      }
      await _yieldToUiThread();
      report(_l10n.catalogProgressApplyUserPatch, 0.42);
      String? userRaw = inlineUserOverlayJson;
      userRaw ??= await readUserCatalogIfExists(userOverlayPath);
      if (userRaw != null) {
        final Object? userDecoded = jsonDecode(userRaw);
        if (userDecoded is Map) {
          mergeSupplementCatalogPatchIntoRoot(
            root,
            jsonMapToStringKeyed(userDecoded),
          );
        }
      }
      await _yieldToUiThread();
      report(_l10n.catalogProgressParseMergedCatalog, 0.58);
      final String mergedJson = jsonEncode(root);
      Map<String, AlchemyCard> next = await _parser.parseJsonStringAsync(
        mergedJson,
        combinationPatchJson: '',
      );
      if (_augmentSyntheticOnyxCatalog) {
        report(_l10n.catalogProgressAddSyntheticOnyx, 0.75);
        final String shopPacksRaw = await rootBundle.loadString(
          'assets/data/shop_packs.json',
        );
        final String scheduleOccRaw = await rootBundle.loadString(
          'assets/data/pack_schedule_occasions.json',
        );
        final String onyxWikiRaw = await rootBundle.loadString(
          'assets/data/onyx_wiki_display_names.json',
        );
        Set<String> allowedOnyxMaterialDisplayNames =
            OnyxWikiAllowlist.displayNameSetFromBundledJson(onyxWikiRaw);
        if (allowedOnyxMaterialDisplayNames.isEmpty) {
          allowedOnyxMaterialDisplayNames =
              ShopPackBundle.occasionAllowlistFromPackScheduleOccasionsJson(
            scheduleOccRaw,
          );
        }
        if (allowedOnyxMaterialDisplayNames.isEmpty) {
          allowedOnyxMaterialDisplayNames =
              ShopPackBundle.uniqueOccasionDisplayNamesFromShopPacksJson(
            shopPacksRaw,
          );
        }
        next = SyntheticOnyxCatalogAugment.mergeIntoCatalog(
          base: next,
          sheet: _fusionOnyxSheet,
          allowedOnyxMaterialDisplayNames: allowedOnyxMaterialDisplayNames,
        );
      }
      await _yieldToUiThread();
      report(_l10n.catalogProgressFinalizeCatalog, 0.92);
      await _applyCatalog(next, message: bundledMessage(next.length));
      report(_l10n.catalogProgressReady, 1.0);
    } on Object catch (e) {
      _loadMessage = _l10n.loadCatalogError(e);
      notifyListeners();
    }
  }

  Future<void> _applyCatalog(
    Map<String, AlchemyCard> next, {
    required String message,
  }) async {
    _catalog = next;
    _fusionParticipantIds = fusionParticipantCardIds(next);
    await _hydrateOwnedFromStore();
    _lastDeckResult = null;
    _loadMessage = message;
    notifyListeners();
  }

  List<OwnedComboEntry> _sanitizeEntries(List<OwnedComboEntry> raw) {
    final List<OwnedComboEntry> out = <OwnedComboEntry>[];
    for (final OwnedComboEntry e in raw) {
      final AlchemyCard? c = _catalog[e.cardId];
      if (c == null || !cardCanFuse(e.cardId)) {
        continue;
      }
      out.add(
        e.copyWith(
          level: e.level.clamp(
            OwnedComboEntry.minLevel,
            OwnedComboEntry.maxLevel,
          ),
        ),
      );
    }
    return out;
  }

  Future<void> pickAndLoadUserCatalogOverlayJson() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(type: FileType.any, withData: true);
    } on Object catch (e, st) {
      _logUiError('pickAndLoadUserCatalogOverlayJson', e, st);
      _loadMessage = _l10n.loadOpenFilePickerFailed(e);
      notifyListeners();
      return;
    }
    if (result == null || result.files.isEmpty) {
      _loadMessage = _l10n.loadImportPatchCancelled;
      notifyListeners();
      return;
    }
    final PlatformFile f = result.files.first;
    Uint8List? bytes = f.bytes;
    if (bytes == null && f.path != null && !kIsWeb) {
      bytes = await readFileAsBytes(f.path!);
    }
    if (bytes == null) {
      _loadMessage = _l10n.loadCouldNotReadFile;
      notifyListeners();
      return;
    }
    try {
      jsonDecode(String.fromCharCodes(bytes));
    } on Object catch (e) {
      _loadMessage = _l10n.loadFileInvalidJson(e);
      notifyListeners();
      return;
    }
    final String? savedPath = await saveUserCatalogOverlayAndReturnPath(bytes);
    final String raw = String.fromCharCodes(bytes);
    if (savedPath != null) {
      await _store.writeUserCatalogOverlayPath(savedPath);
      _userCatalogOverlayPath = savedPath;
    } else {
      await _store.writeUserCatalogOverlayPath(null);
      _userCatalogOverlayPath = null;
    }
    await _loadMergedCatalog(
      userOverlayPath: _userCatalogOverlayPath,
      inlineUserOverlayJson: savedPath == null ? raw : null,
      bundledMessage: (int n) => savedPath != null
          ? _l10n.loadPatchSavedCatalogRebuilt(n)
          : _l10n.loadPatchAppliedSessionOnly(n),
      onProgress: null,
    );
  }

  Future<void> clearUserCatalogOverlayAndReload() async {
    await _store.writeUserCatalogOverlayPath(null);
    _userCatalogOverlayPath = null;
    await _loadMergedCatalog(
      userOverlayPath: null,
      inlineUserOverlayJson: null,
      bundledMessage: (int n) => _l10n.loadUserPatchReset(n),
      onProgress: null,
    );
  }
}
