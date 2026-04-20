part of 'app_controller.dart';

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, unused_element

extension AppControllerExportImportExtension on AppController {
  Future<void> exportDeckSettingsToJsonFile({
    required bool exportAllDecks,
    String? singleDeckId,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final bool permissionGranted = await ensureExportWritePermission();
      if (!permissionGranted) {
        _loadMessage = _l10n.loadNoStoragePermission;
        notifyListeners();
        return;
      }
      List<DeckProfile> source = <DeckProfile>[];
      if (exportAllDecks) {
        source = List<DeckProfile>.from(_deckProfiles);
      } else {
        final String? deckId = singleDeckId?.trim();
        if (deckId == null || deckId.isEmpty) {
          _loadMessage = _l10n.loadDeckSettingsExportFailedNoDeck;
          notifyListeners();
          return;
        }
        for (final DeckProfile profile in _deckProfiles) {
          if (profile.id == deckId) {
            source = <DeckProfile>[profile];
            break;
          }
        }
      }
      if (source.isEmpty) {
        _loadMessage = _l10n.loadDeckSettingsExportEmpty;
        notifyListeners();
        return;
      }
      final List<Map<String, Object?>> deckRows = <Map<String, Object?>>[];
      for (final DeckProfile profile in source) {
        deckRows.add(
          <String, Object?>{
            'name': profile.name.trim(),
            'settings': profile.settings.copyWith(clearSeedCardId: true).toJson(),
          },
        );
      }
      final String payload = const JsonEncoder.withIndent('  ').convert(
        <String, Object?>{
          'type': 'little_alchemist_deck_settings_v1',
          'createdAtUtc': DateTime.now().toUtc().toIso8601String(),
          'decks': deckRows,
        },
      );
      final String ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final String fileName = 'deck_settings_$ts.json';
      final Uint8List exportBytes = Uint8List.fromList(utf8.encode('$payload\n'));
      final ShareResultStatus? shareStatus = await shareFileForSaving(
        bytes: exportBytes,
        fileName: fileName,
        mimeType: 'application/json',
        sharePositionOrigin: sharePositionOrigin,
      );
      if (shareStatus == ShareResultStatus.success ||
          shareStatus == ShareResultStatus.dismissed) {
        _loadMessage = _l10n.loadShareSheetOpenedSaveToFiles;
        notifyListeners();
        return;
      }
      if (supportsDirectSaveDialog()) {
        final String? savePath = await pickSaveTextPath(fileName);
        if (savePath != null && savePath.isNotEmpty) {
          await writeBytesToPath(savePath, exportBytes);
          _loadMessage = _l10n.loadDeckSettingsExported(deckRows.length, savePath);
          notifyListeners();
          return;
        }
      }
      final String fallbackPath = await writeBytesToAppDocumentsFile(
        fileName,
        exportBytes,
      );
      _loadMessage = _l10n.loadDeckSettingsSavedToAppFiles(fallbackPath);
      notifyListeners();
    } on Object catch (e, st) {
      _logUiError('exportDeckSettingsToJsonFile', e, st);
      _loadMessage = _l10n.loadDeckSettingsExportError(e);
      notifyListeners();
    }
  }

  Future<DeckSettingsImportResult?> importDeckSettingsFromJsonFile() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(type: FileType.any, withData: true);
    } on Object catch (e, st) {
      _logUiError('importDeckSettingsFromJsonFile', e, st);
      _loadMessage = _l10n.loadOpenFilePickerFailed(e);
      notifyListeners();
      return null;
    }
    if (result == null || result.files.isEmpty) {
      _loadMessage = _l10n.loadImportDeckSettingsCancelled;
      notifyListeners();
      return null;
    }
    final PlatformFile f = result.files.first;
    Uint8List? bytes = f.bytes;
    if (bytes == null && f.path != null && !kIsWeb) {
      bytes = await readFileAsBytes(f.path!);
    }
    if (bytes == null || bytes.isEmpty) {
      _loadMessage = _l10n.loadCouldNotReadDeckSettingsFile;
      notifyListeners();
      return const DeckSettingsImportResult(importedCount: 0, skippedCount: 0);
    }
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes, allowMalformed: true));
    } on Object catch (e) {
      _loadMessage = _l10n.loadDeckSettingsInvalidJson(e);
      notifyListeners();
      return const DeckSettingsImportResult(importedCount: 0, skippedCount: 0);
    }
    if (decoded is! Map) {
      _loadMessage = _l10n.loadDeckSettingsInvalidStructure;
      notifyListeners();
      return const DeckSettingsImportResult(importedCount: 0, skippedCount: 0);
    }
    final String? type = decoded['type'] as String?;
    if (type != 'little_alchemist_deck_settings_v1') {
      _loadMessage = _l10n.loadDeckSettingsUnsupportedFormat;
      notifyListeners();
      return const DeckSettingsImportResult(importedCount: 0, skippedCount: 0);
    }
    final Object? rawDecks = decoded['decks'];
    if (rawDecks is! List) {
      _loadMessage = _l10n.loadDeckSettingsInvalidStructure;
      notifyListeners();
      return const DeckSettingsImportResult(importedCount: 0, skippedCount: 0);
    }
    final List<DeckProfile> incoming = <DeckProfile>[];
    int skipped = 0;
    for (final Object? rawDeck in rawDecks) {
      final _ImportedDeckSettings? parsed = _parseImportedDeckSettings(rawDeck);
      if (parsed == null) {
        skipped++;
        continue;
      }
      incoming.add(
        DeckProfile(
          id: CollectionStore.createEntryId(),
          name: parsed.name,
          settings: parsed.settings,
        ),
      );
    }
    if (incoming.isEmpty) {
      _loadMessage = _l10n.loadDeckSettingsNothingImported(skipped);
      notifyListeners();
      return DeckSettingsImportResult(importedCount: 0, skippedCount: skipped);
    }
    final List<DeckProfile> previous = List<DeckProfile>.from(_deckProfiles);
    _deckProfiles = List<DeckProfile>.from(_deckProfiles)..addAll(incoming);
    final bool saveOk = await _store.writeDeckProfiles(_deckProfiles);
    if (!saveOk) {
      _deckProfiles = previous;
      _loadMessage = _l10n.loadCouldNotSaveDecks;
      notifyListeners();
      return DeckSettingsImportResult(importedCount: 0, skippedCount: skipped);
    }
    _loadMessage = _l10n.loadDeckSettingsImported(incoming.length, skipped);
    notifyListeners();
    return DeckSettingsImportResult(
      importedCount: incoming.length,
      skippedCount: skipped,
    );
  }

  Future<void> exportDownloadedCardImagesZip({Rect? sharePositionOrigin}) async {
    try {
      final bool permissionGranted = await ensureExportWritePermission();
      if (!permissionGranted) {
        _loadMessage = _l10n.loadNoStoragePermission;
        notifyListeners();
        return;
      }
      final Map<String, String?> wikiUrls = _store.readWikiImageUrlMap();
      final List<MapEntry<String, String?>> rows = wikiUrls.entries
          .where((MapEntry<String, String?> e) => e.value != null && e.value!.isNotEmpty)
          .toList()
        ..sort(
          (MapEntry<String, String?> a, MapEntry<String, String?> b) =>
              a.key.compareTo(b.key),
        );
      final Archive zip = Archive();
      final Set<String> usedNames = <String>{};
      /// One zip entry per distinct image URL — the persisted wiki map may list
      /// several keys (e.g. display name vs wiki stem) for the same URL.
      final Set<String> exportedImageUrls = <String>{};
      int added = 0;
      for (final MapEntry<String, String?> row in rows) {
        final String cacheKey = row.key;
        final bool onyx = WikiImageUrlService.isOnyxWikiCacheKey(cacheKey);
        final String displayName =
            WikiImageUrlService.displayNameFromWikiCacheKey(cacheKey);
        final bool hasBundled = await hasBundledCardImageForDisplayName(
          displayName,
          isOnyxTier: onyx,
        );
        if (hasBundled) {
          continue;
        }
        final String url = row.value!;
        if (exportedImageUrls.contains(url)) {
          continue;
        }
        final FileInfo? info = await cardImageCacheManager.getFileFromCache(url);
        if (info == null || !await info.file.exists()) {
          continue;
        }
        final Uint8List bytes = await info.file.readAsBytes();
        if (bytes.isEmpty) {
          continue;
        }
        final String base = _safeExportFileName(
          WikiImageUrlService.wikiFileStemFromWikiImageCacheKey(cacheKey),
        );
        final String ext = _imageExtensionFromUrl(url);
        String fileName = '$base.$ext';
        int n = 2;
        while (usedNames.contains(fileName)) {
          fileName = '${base}_$n.$ext';
          n++;
        }
        usedNames.add(fileName);
        exportedImageUrls.add(url);
        zip.addFile(ArchiveFile(fileName, bytes.length, bytes));
        added++;
      }
      try {
        final String shopRaw =
            await rootBundle.loadString('assets/data/shop_packs.json');
        final String shopContentsRaw =
            await rootBundle.loadString('assets/data/shop_pack_contents.json');
        final ShopPackBundle shopBundle =
            ShopPackBundle.parse(shopRaw, shopContentsRaw);
        final String specialRaw =
            await rootBundle.loadString('assets/data/special_packs.json');
        final SpecialPackCatalog cat = SpecialPackCatalog.parse(specialRaw);
        for (final SpecialPackEntry pack in cat.packs) {
          final String url = pack.wikiImageUrl.trim();
          if (url.isEmpty) {
            continue;
          }
          if (exportedImageUrls.contains(url)) {
            continue;
          }
          final ShopPackEntry? row = pack.primaryScheduleRow(shopBundle);
          final String bundledTry = row?.imageFile ?? pack.selectorFile;
          if (await hasBundledShopPackImageAsset(bundledTry)) {
            continue;
          }
          final FileInfo? info = await cardImageCacheManager.getFileFromCache(url);
          if (info == null || !await info.file.exists()) {
            continue;
          }
          final Uint8List bytes = await info.file.readAsBytes();
          if (bytes.isEmpty) {
            continue;
          }
          final String base = _safeExportFileName(
            'shop_pack_${pack.wikiSlug.replaceAll('/', '_')}',
          );
          final String ext = _imageExtensionFromUrl(url);
          String fileName = '$base.$ext';
          int n = 2;
          while (usedNames.contains(fileName)) {
            fileName = '${base}_$n.$ext';
            n++;
          }
          usedNames.add(fileName);
          exportedImageUrls.add(url);
          zip.addFile(ArchiveFile(fileName, bytes.length, bytes));
          added++;
        }
      } on Object {
        // Missing asset or parse error — card export still valid.
      }
      if (added == 0) {
        _loadMessage = _l10n.loadNoNewDownloadedFilesForExport;
        notifyListeners();
        return;
      }
      final List<int> encoded = ZipEncoder().encode(zip);
      final String ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final String fileName = 'card_images_$ts.zip';
      final Uint8List exportBytes = Uint8List.fromList(encoded);
      final ShareResultStatus? shareStatus = await shareFileForSaving(
        bytes: exportBytes,
        fileName: fileName,
        mimeType: 'application/zip',
        sharePositionOrigin: sharePositionOrigin,
      );
      if (shareStatus == ShareResultStatus.success ||
          shareStatus == ShareResultStatus.dismissed) {
        _loadMessage = _l10n.loadShareSheetOpenedSaveToFiles;
        notifyListeners();
        return;
      }
      if (supportsDirectSaveDialog()) {
        final String? savePath = await pickSaveZipPath(fileName);
        if (savePath != null && savePath.isNotEmpty) {
          await writeBytesToPath(savePath, exportBytes);
          _loadMessage = _l10n.loadExportedImagesZip(added, savePath);
          notifyListeners();
          return;
        }
      }
      final String fallbackPath = await writeBytesToAppDocumentsFile(
        'card_images_$ts.zip',
        exportBytes,
      );
      _loadMessage = _l10n.loadZipSavedToAppFiles(fallbackPath);
      notifyListeners();
    } on Object catch (e, st) {
      _logUiError('exportDownloadedCardImagesZip', e, st);
      _loadMessage = _l10n.loadZipExportError(e);
      notifyListeners();
    }
  }

  Future<void> exportCollectionToSimpleTextFile({Rect? sharePositionOrigin}) async {
    try {
      final bool permissionGranted = await ensureExportWritePermission();
      if (!permissionGranted) {
        _loadMessage = _l10n.loadNoStoragePermission;
        notifyListeners();
        return;
      }
      if (_ownedComboEntries.isEmpty) {
        _loadMessage = _l10n.loadCollectionEmptyNothingToExport;
        notifyListeners();
        return;
      }
      final List<String> lines = <String>[];
      for (final OwnedComboEntry entry in _ownedComboEntries) {
        final AlchemyCard? card = _catalog[entry.cardId];
        if (card == null) {
          continue;
        }
        final int level = entry.level.clamp(
          OwnedComboEntry.minLevel,
          OwnedComboEntry.maxLevel,
        );
        final String exportCardName = _collectionImportExportDisplayName(card);
        lines.add('$exportCardName:$level');
      }
      if (lines.isEmpty) {
        _loadMessage = _l10n.loadNoValidCardsForExport;
        notifyListeners();
        return;
      }
      final String ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final String fileName = 'collection_$ts.txt';
      final String data = '${lines.join('\n')}\n';
      final Uint8List exportBytes = Uint8List.fromList(utf8.encode(data));
      final ShareResultStatus? shareStatus = await shareFileForSaving(
        bytes: exportBytes,
        fileName: fileName,
        mimeType: 'text/plain',
        sharePositionOrigin: sharePositionOrigin,
      );
      if (shareStatus == ShareResultStatus.success ||
          shareStatus == ShareResultStatus.dismissed) {
        _loadMessage = _l10n.loadShareSheetOpenedSaveToFiles;
        notifyListeners();
        return;
      }
      if (supportsDirectSaveDialog()) {
        final String? savePath = await pickSaveTextPath(fileName);
        if (savePath != null && savePath.isNotEmpty) {
          await writeBytesToPath(savePath, exportBytes);
          _loadMessage = _l10n.loadExportedCards(lines.length, savePath);
          notifyListeners();
          return;
        }
      }
      final String fallbackPath = await writeBytesToAppDocumentsFile(
        'collection_$ts.txt',
        exportBytes,
      );
      _loadMessage = _l10n.loadCollectionFileSavedToAppFiles(fallbackPath);
      notifyListeners();
    } on Object catch (e, st) {
      _logUiError('exportCollectionToSimpleTextFile', e, st);
      _loadMessage = _l10n.loadCollectionExportError(e);
      notifyListeners();
    }
  }

  Future<CollectionTextImportResult?> importCollectionFromSimpleTextFile() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(type: FileType.any, withData: true);
    } on Object catch (e, st) {
      _logUiError('importCollectionFromSimpleTextFile', e, st);
      _loadMessage = _l10n.loadOpenFilePickerFailed(e);
      notifyListeners();
      return null;
    }
    if (result == null || result.files.isEmpty) {
      _loadMessage = _l10n.loadImportCollectionCancelled;
      notifyListeners();
      return null;
    }
    final PlatformFile f = result.files.first;
    Uint8List? bytes = f.bytes;
    if (bytes == null && f.path != null && !kIsWeb) {
      bytes = await readFileAsBytes(f.path!);
    }
    if (bytes == null || bytes.isEmpty) {
      _loadMessage = _l10n.loadCouldNotReadCollectionFile;
      notifyListeners();
      return const CollectionTextImportResult(
        importedCount: 0,
        skippedInvalidLines: 0,
        notFoundCardNames: <String>[],
      );
    }
    final String raw = utf8.decode(bytes, allowMalformed: true);
    final List<String> lines = raw.split(RegExp(r'\r?\n'));
    final Map<String, AlchemyCard> byDisplayName = <String, AlchemyCard>{};
    for (final AlchemyCard card in _catalog.values) {
      final String key = _collectionImportLookupKey(
        card.displayName,
        isOnyx: _isOnyxCard(card),
      );
      if (key.isEmpty || byDisplayName.containsKey(key)) {
        continue;
      }
      byDisplayName[key] = card;
    }
    final List<OwnedComboEntry> imported = <OwnedComboEntry>[];
    final Set<String> notFound = <String>{};
    int skippedInvalidLines = 0;
    for (final String lineRaw in lines) {
      final String line = lineRaw.trim();
      if (line.isEmpty) {
        continue;
      }
      final int colon = line.lastIndexOf(':');
      if (colon <= 0 || colon >= line.length - 1) {
        skippedInvalidLines++;
        continue;
      }
      final String cardName = line.substring(0, colon).trim();
      final String levelRaw = line.substring(colon + 1).trim();
      final int? levelParsed = int.tryParse(levelRaw);
      if (cardName.isEmpty || levelParsed == null) {
        skippedInvalidLines++;
        continue;
      }
      final AlchemyCard? card =
          byDisplayName[_collectionImportLookupKey(cardName)];
      if (card == null || !cardCanFuse(card.cardId)) {
        notFound.add(cardName);
        continue;
      }
      imported.add(
        OwnedComboEntry(
          entryId: CollectionStore.createEntryId(),
          cardId: card.cardId,
          tier: clampInstanceTierToCatalog(
            card,
            comboTierFromCatalogRarity(card.rarity),
          ),
          level: levelParsed.clamp(
            OwnedComboEntry.minLevel,
            OwnedComboEntry.maxLevel,
          ),
        ),
      );
    }
    _ownedComboEntries = imported;
    await _saveOwnedEntries();
    _lastDeckResult = null;
    _loadMessage = _l10n.loadImportCompleted(
      imported.length,
      skippedInvalidLines,
      notFound.length,
    );
    notifyListeners();
    return CollectionTextImportResult(
      importedCount: imported.length,
      skippedInvalidLines: skippedInvalidLines,
      notFoundCardNames: notFound.toList()..sort(),
    );
  }

  String _safeExportFileName(String value) {
    final String trimmed = value.trim();
    final String replaced = trimmed.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );
    final String compact = replaced.replaceAll(RegExp(r'\s+'), ' ');
    if (compact.isEmpty) {
      return 'card_image';
    }
    return compact;
  }

  bool _isOnyxCard(AlchemyCard card) {
    return comboTierFromCatalogRarity(card.rarity) == ComboTier.onyx;
  }

  String _collectionImportExportDisplayName(AlchemyCard card) {
    final String normalized = card.displayName.trim();
    if (_isOnyxCard(card)) {
      return '$normalized Onyx';
    }
    return normalized;
  }

  String _collectionImportLookupKey(
    String rawName, {
    bool? isOnyx,
  }) {
    String normalized = rawName.trim();
    bool onyxFlag = isOnyx ?? false;
    final String lower = normalized.toLowerCase();
    const String suffix = ' onyx';
    if (isOnyx == null && lower.endsWith(suffix)) {
      onyxFlag = true;
      normalized = normalized.substring(0, normalized.length - suffix.length).trim();
    }
    final String base = normalized.toLowerCase();
    if (base.isEmpty) {
      return '';
    }
    return onyxFlag ? '$base|onyx' : '$base|base';
  }

  String _imageExtensionFromUrl(String url) {
    final String lower = url.toLowerCase();
    if (lower.contains('.webp')) {
      return 'webp';
    }
    if (lower.contains('.jpg') || lower.contains('.jpeg')) {
      return 'jpg';
    }
    if (lower.contains('.gif')) {
      return 'gif';
    }
    return 'png';
  }

  _ImportedDeckSettings? _parseImportedDeckSettings(Object? rawDeck) {
    if (rawDeck is! Map) {
      return null;
    }
    final String? name = _validImportedDeckName(rawDeck['name']);
    final Map<String, Object?>? settingsMap = _asStringObjectMap(rawDeck['settings']);
    if (name == null || settingsMap == null) {
      return null;
    }
    if (!_isValidDeckSettingsJson(settingsMap)) {
      return null;
    }
    return _ImportedDeckSettings(
      name: name,
      settings: DeckSettings.fromJson(settingsMap).copyWith(clearSeedCardId: true),
    );
  }

  String? _validImportedDeckName(Object? raw) {
    if (raw is! String) {
      return null;
    }
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.length > 64 ? trimmed.substring(0, 64) : trimmed;
  }

  Map<String, Object?>? _asStringObjectMap(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    return raw.map(
      (Object? key, Object? value) => MapEntry<String, Object?>(key.toString(), value),
    );
  }

  bool _isValidDeckSettingsJson(Map<String, Object?> json) {
    final int? deckSize = (json['deckSize'] as num?)?.toInt();
    final int? maxNonFusionCards = (json['maxNonFusionCards'] as num?)?.toInt();
    final Object? focusPresetRaw = json['focusPreset'];
    final double? comboVsStatsBalance = (json['comboVsStatsBalance'] as num?)?.toDouble();
    final double? comboVsHandBalance = (json['comboVsHandBalance'] as num?)?.toDouble();
    final Map<String, Object?>? rarityRules = _asStringObjectMap(json['rarityRules']);
    if (deckSize == null ||
        deckSize < DeckSettings.minDeckSize ||
        deckSize > DeckSettings.maxDeckSize) {
      return false;
    }
    if (maxNonFusionCards == null ||
        maxNonFusionCards < DeckSettings.minMaxNonFusionCards ||
        maxNonFusionCards > DeckSettings.maxMaxNonFusionCards) {
      return false;
    }
    if (focusPresetRaw is! String ||
        !DeckFocusPreset.values.any((DeckFocusPreset p) => p.name == focusPresetRaw)) {
      return false;
    }
    if (comboVsStatsBalance == null ||
        comboVsStatsBalance < 0.0 ||
        comboVsStatsBalance > 1.0) {
      return false;
    }
    if (comboVsHandBalance != null &&
        (comboVsHandBalance < 0.0 || comboVsHandBalance > 1.0)) {
      return false;
    }
    if (rarityRules == null) {
      return false;
    }
    return _isValidRarityRulesJson(rarityRules);
  }

  bool _isValidRarityRulesJson(Map<String, Object?> json) {
    const List<String> keys = <String>['bronze', 'silver', 'gold', 'diamond', 'onyx'];
    for (final String key in keys) {
      final Map<String, Object?>? rule = _asStringObjectMap(json[key]);
      final int? minLevel = (rule?['minLevel'] as num?)?.toInt();
      if (rule == null || minLevel == null || minLevel < 1 || minLevel > 6) {
        return false;
      }
    }
    return true;
  }
}

@immutable
class _ImportedDeckSettings {
  const _ImportedDeckSettings({
    required this.name,
    required this.settings,
  });

  final String name;
  final DeckSettings settings;
}
