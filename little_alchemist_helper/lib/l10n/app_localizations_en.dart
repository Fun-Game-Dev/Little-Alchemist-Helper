// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Little Alchemist Helper';

  @override
  String startupError(Object error) {
    return 'Startup error: $error';
  }

  @override
  String get tabDeck => 'Deck';

  @override
  String get tabCollection => 'Collection';

  @override
  String get tabCombo => 'Combo';

  @override
  String get tabImport => 'Files';

  @override
  String get tabSettings => 'Settings';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionDone => 'Done';

  @override
  String get labelSort => 'Sort';

  @override
  String get labelCollection => 'Collection';

  @override
  String get labelAll => 'All';

  @override
  String get presenceInCollection => 'In collection';

  @override
  String get presenceNotInCollection => 'Not in collection';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByRarity => 'Rarity';

  @override
  String get sortByPower => 'Power';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierDiamond => 'Diamond';

  @override
  String get tierOnyx => 'Onyx';

  @override
  String get levelFused => 'Fusion';

  @override
  String levelShort(Object level) {
    return 'Lv. $level';
  }

  @override
  String get rarityUnknown => '-';

  @override
  String get deckActive => 'Active deck';

  @override
  String get deckProfile => 'Profile';

  @override
  String get deckNew => 'New deck';

  @override
  String get deckDeleteThis => 'Delete this deck';

  @override
  String get deckDeleteConfirmTitle => 'Delete deck?';

  @override
  String deckDeleteConfirmBody(Object name) {
    return '\"$name\" will be deleted.';
  }

  @override
  String get deckOptimizeButton => 'Build best combo set';

  @override
  String get deckEditSettings => 'Settings and auto-fill';

  @override
  String get saveFailedGeneric => 'Could not save changes.';

  @override
  String get settingsMedia => 'Media';

  @override
  String get settingsLoadWikiImages => 'Load wiki images';

  @override
  String get settingsLoadWikiImagesSubtitle => 'Use Little Alchemist Wiki images for cards. Disabled by default.';

  @override
  String get settingsWikiThanksTitle => 'Thanks';

  @override
  String get settingsWikiThanksSubtitle => 'Card images are provided by the Little Alchemist Wiki community.';

  @override
  String get settingsWikiOpenSite => 'Open Little Alchemist Wiki';

  @override
  String get settingsWikiOpenFailed => 'Could not open the wiki site.';

  @override
  String get settingsCatalogStatsTitle => 'Catalog stats by rarity';

  @override
  String settingsCatalogStatsTotal(Object count) {
    return 'Total cards: $count';
  }

  @override
  String get settingsAppInfoTitle => 'About app';

  @override
  String settingsAppVersion(Object version) {
    return 'Version: $version';
  }

  @override
  String settingsAppBuild(Object build) {
    return 'Build: $build';
  }

  @override
  String collectionDeleteOneFromGroup(Object name, Object count) {
    return 'Delete one \"$name\"? Group has $count duplicates.';
  }

  @override
  String collectionDeleteOne(Object name) {
    return 'Delete \"$name\" from collection?';
  }

  @override
  String get collectionDeleteTitle => 'Remove from collection';

  @override
  String collectionLimitWarning(Object limit, Object names) {
    return 'You have more than $limit cards with one name: $names. This set is not allowed in a deck.';
  }

  @override
  String get collectionAddOne => 'One card';

  @override
  String get collectionAddMany => 'Bulk add';

  @override
  String get collectionCollapseDuplicates => 'Group duplicates';

  @override
  String collectionHint(Object limit) {
    return 'Each row is one card. To edit, remove and add again. Deck limit: up to $limit cards with one name.';
  }

  @override
  String collectionStats(Object kinds, Object copies) {
    return '$kinds kinds - $copies copies';
  }

  @override
  String get collectionEmpty => 'Collection is empty. Add cards with buttons above.';

  @override
  String collectionDuplicatesCount(Object count) {
    return 'x$count duplicates';
  }

  @override
  String get collectionDeleteOneTooltip => 'Delete one';

  @override
  String get collectionAddToCollection => 'Add to collection';

  @override
  String get deckNameRequired => 'Enter deck name.';

  @override
  String get deckName => 'Deck name';

  @override
  String get deckSeedCard => 'Seed card';

  @override
  String get deckNotSelected => 'Not selected';

  @override
  String get deckSeedHint => 'Pick a card from collection. It will be first.';

  @override
  String deckLevel(Object level) {
    return 'Level: $level';
  }

  @override
  String get deckSelectCard => 'Pick card';

  @override
  String get deckPickSeed => 'Seed card';

  @override
  String get deckFillType => 'Fill mode';

  @override
  String get deckFillHint => 'After seed card, cards are added one by one.';

  @override
  String deckSize(Object size) {
    return 'Deck size: $size';
  }

  @override
  String deckMaxNonFusion(Object count) {
    return 'Max non-Fusion cards: $count';
  }

  @override
  String get deckRarityRules => 'Rarity rules';

  @override
  String deckMinComboTier(Object tier) {
    return 'Min combo rarity considered: $tier';
  }

  @override
  String get deckRarityRulesHint => 'Set minimum level for each rarity.';

  @override
  String deckMinLevel(Object level) {
    return 'Min level: $level';
  }

  @override
  String get deckNoSeedCandidates => 'No suitable seed cards in collection.';

  @override
  String get deckPickSeedTitle => 'Pick seed card from collection';

  @override
  String get comboLabIntro => 'Pick two cards and levels. Missing Fusion result for a pair can be normal.';

  @override
  String get comboCardA => 'Card A';

  @override
  String get comboCardB => 'Card B';

  @override
  String get comboChange => 'Change';

  @override
  String get comboPickA => 'Pick card A';

  @override
  String get comboPickB => 'Pick card B';

  @override
  String get comboResult => 'Fusion result';

  @override
  String get comboPickBoth => 'Pick both cards.';

  @override
  String comboNoRecipe(Object a, Object b) {
    return 'No Fusion recipe for \"$a\" + \"$b\".';
  }

  @override
  String comboBattleLevel(Object level) {
    return 'Battle Lv. $level';
  }

  @override
  String comboBaseStats(Object attack, Object defense) {
    return 'Base stats: $attack / $defense';
  }

  @override
  String get comboMaterialsDoubleOnyx => 'Materials: two onyx tiers.';

  @override
  String get comboMaterialsMixed => 'Materials: one onyx and one lower tier.';

  @override
  String get importDataTitle => 'Files';

  @override
  String get importDataOrder => 'Catalog build order:\n1) built-in AlchemyCardData.json\n2) assets/data_from_exel.txt supplement\n3) built-in CombinationPatch.json\n4) optional user JSON patch (additive only).';

  @override
  String get importPickPatch => 'Pick user JSON patch';

  @override
  String get importResetPatch => 'Reset user patch only';

  @override
  String get importClearCollectionQuestion => 'Clear collection?';

  @override
  String get importClearCollection => 'Clear combo-card collection';

  @override
  String get importLastMessage => 'Last message';

  @override
  String get catalogNoCards => 'No cards';

  @override
  String get catalogPickCard => 'Pick card';

  @override
  String catalogInstanceLevel(Object level) {
    return 'Instance level: $level';
  }

  @override
  String get catalogLevelWillBeSaved => 'Level will be used for next add.';

  @override
  String catalogFrameRarity(Object tier, Object rarity) {
    return 'Frame rarity: $tier ($rarity).';
  }

  @override
  String get catalogSearchHint => 'Search in catalog';

  @override
  String get catalogRarityFilterTitle => 'Data rarity filter';

  @override
  String catalogBulkIntro(Object kinds) {
    return 'Cards from catalog will be added by filters (now $kinds kinds).';
  }

  @override
  String catalogAllowOverLimit(Object limit) {
    return 'Allow over limit ($limit per deck name)';
  }

  @override
  String get catalogOverLimitHint => 'If off, extra copies by name are skipped.';

  @override
  String get catalogCopiesPerCard => 'Copies per card';

  @override
  String catalogAllNewLevel(Object level) {
    return 'Level for all new cards: $level';
  }

  @override
  String get catalogLimitNotApplied => 'Name limit is not applied.';

  @override
  String catalogLimitAppliedHint(Object limit) {
    return 'With limit $limit per name, some copies may be skipped.';
  }

  @override
  String get catalogBulkAddTitle => 'Bulk add';

  @override
  String catalogBulkAddConfirm(Object total, Object kinds, Object copies, Object level, Object limitLine) {
    return 'Add up to $total cards ($kinds x $copies), level $level.\n\n$limitLine';
  }

  @override
  String catalogAddAll(Object kinds) {
    return 'Add all ($kinds kinds)';
  }

  @override
  String get importReplaceCollectionTitle => 'Replace current collection?';

  @override
  String get importReplaceCollectionBody => 'Current collection is not empty. Import will delete current data and replace it with file contents.';

  @override
  String get importReplaceCollectionConfirm => 'Replace';

  @override
  String get importNotFoundTitle => 'Cards not found';

  @override
  String importNotFoundBody(Object names) {
    return 'These cards are missing in catalog and were not imported:\n\n$names';
  }

  @override
  String get importShareZip => 'Share ZIP with newly downloaded images';

  @override
  String get importUserCollectionTitle => 'User collection';

  @override
  String get importSimpleFormatHint => 'Simple file format: one card per line -> card:level';

  @override
  String get importShareCollectionTxt => 'Share collection (TXT)';

  @override
  String get importLoadCollectionTxt => 'Import collection from TXT';

  @override
  String get importDeckSettingsTitle => 'Deck settings';

  @override
  String get importDeckSettingsHint => 'Export/import only deck auto-build settings. Invalid deck entries are skipped during import.';

  @override
  String get importExportDeckSettings => 'Export deck settings (JSON)';

  @override
  String get importLoadDeckSettings => 'Import deck settings (JSON)';

  @override
  String get importDeckSettingsExportAll => 'Export all decks';

  @override
  String importDeckSettingsExportOne(Object name) {
    return 'Export \"$name\"';
  }

  @override
  String get settingsDecksTitle => 'Decks';

  @override
  String get settingsDecksHint => 'Manage deck profiles and auto-build parameters in Deck -> Settings and auto-fill.';

  @override
  String get settingsComboCatalogTitle => 'Combo catalog';

  @override
  String get settingsSyntheticOnyxTitle => 'Synthetic onyx Fusion results';

  @override
  String get settingsSyntheticOnyxSubtitle => 'Adds onyx copies with boosted A/D and extra result rows for two onyx materials.';

  @override
  String get settingsFilesTitle => 'Files';

  @override
  String get settingsFilesHint => 'Import/export data, patches, and app service files.';

  @override
  String get settingsOpenFilesScreen => 'Open files screen';

  @override
  String get settingsCatalogStatsByAbilityTitle => 'Breakdown by ability and rarity';

  @override
  String get settingsCatalogStatsNoAbility => 'No ability';

  @override
  String get deckFocusAttack => 'Attack';

  @override
  String get deckFocusDefense => 'Defense';

  @override
  String get deckFocusSumStats => 'Total stats';

  @override
  String deckStatusSummary(Object focus, Object size, Object seed) {
    return '$focus · size $size · seed: $seed';
  }

  @override
  String get deckSeedNone => 'none';

  @override
  String get deckNeedAtLeastOneCard => 'Add at least one combo card to collection.';

  @override
  String deckNotEnoughCardsForSize(Object size) {
    return 'Collection has fewer cards than deck size ($size).';
  }

  @override
  String get deckTapBuildHint => 'Tap the button above to build.';

  @override
  String get deckHeuristicApprox => 'Fast heuristic used; result is approximate.';

  @override
  String deckPoolTruncated(Object count) {
    return 'Used top-$count cards by solo score (pool limit).';
  }

  @override
  String deckScoreSummary(Object total, Object attack, Object defense, Object combo) {
    return 'Score: $total (attack $attack · defense $defense · combo $combo)';
  }

  @override
  String deckDefaultName(Object index) {
    return 'Deck $index';
  }

  @override
  String deckComboVsStatsBalance(Object value) {
    return 'Stats/Combo balance: $value';
  }

  @override
  String get deckComboVsStatsBalanceHint => '0 - only selected stats, 1 - only number of combos';

  @override
  String deckComboVsHandBalance(Object value) {
    return 'Combo / random hand balance: $value';
  }

  @override
  String get deckComboVsHandBalanceHint => '0 - only pairwise picks (stats/combos above), 1 - only expected strength of a random 5-card hand by tier';

  @override
  String comboResultId(Object id) {
    return 'id $id';
  }

  @override
  String comboPreviewStatsFromSheet(Object attack, Object defense) {
    return 'A/D from fusion_onyx_stats: $attack / $defense';
  }

  @override
  String comboPreviewStatsEstimated(Object attack, Object defense) {
    return 'Estimated A/D: $attack / $defense';
  }

  @override
  String get loadSaveDecksStorageFailed => 'Failed to save decks to storage. Deck settings may be lost after restart.';

  @override
  String loadCatalogLoaded(Object count) {
    return 'Catalog loaded: AlchemyCardData + Excel + patches ($count cards)';
  }

  @override
  String loadCatalogError(Object error) {
    return 'Catalog load error: $error';
  }

  @override
  String loadOpenFilePickerFailed(Object error) {
    return 'Could not open file picker: $error';
  }

  @override
  String get loadImportPatchCancelled => 'Patch import cancelled: file not selected.';

  @override
  String get loadCouldNotReadFile => 'Could not read file.';

  @override
  String loadFileInvalidJson(Object error) {
    return 'File is not valid JSON: $error';
  }

  @override
  String loadPatchSavedCatalogRebuilt(Object count) {
    return 'Patch saved; catalog rebuilt ($count cards)';
  }

  @override
  String loadPatchAppliedSessionOnly(Object count) {
    return 'Patch applied for current session ($count cards), path not saved';
  }

  @override
  String loadUserPatchReset(Object count) {
    return 'User patch reset; catalog ($count cards)';
  }

  @override
  String get loadNoStoragePermission => 'No permission to save files. Allow storage access in app settings.';

  @override
  String get loadNoImageDataForExport => 'No image data available for export.';

  @override
  String get loadNoNewDownloadedFilesForExport => 'No newly downloaded files to export (images from assets/images are excluded).';

  @override
  String get loadShareSheetOpenedSaveToFiles => 'System Share sheet opened. Select Save to Files and destination folder.';

  @override
  String loadExportedImagesZip(Object count, Object path) {
    return 'Exported images: $count\nZIP: $path';
  }

  @override
  String loadZipSavedToAppFiles(Object path) {
    return 'System save dialog is unavailable. ZIP saved to app files:\n$path';
  }

  @override
  String loadZipExportError(Object error) {
    return 'ZIP export error: $error';
  }

  @override
  String get loadCollectionEmptyNothingToExport => 'Collection is empty, nothing to export.';

  @override
  String get loadNoValidCardsForExport => 'No valid cards found for export.';

  @override
  String loadExportedCards(Object count, Object path) {
    return 'Exported cards: $count\nFile: $path';
  }

  @override
  String loadCollectionFileSavedToAppFiles(Object path) {
    return 'System save dialog is unavailable. Collection file saved to app files:\n$path';
  }

  @override
  String loadCollectionExportError(Object error) {
    return 'Collection export error: $error';
  }

  @override
  String get loadImportCollectionCancelled => 'Collection import cancelled: file not selected.';

  @override
  String get loadCouldNotReadCollectionFile => 'Could not read collection file.';

  @override
  String loadImportCompleted(Object imported, Object skipped, Object notFound) {
    return 'Import completed: $imported cards. Skipped lines: $skipped. Cards not found: $notFound.';
  }

  @override
  String get loadCouldNotSaveDecks => 'Could not save decks.';

  @override
  String get loadDeckSettingsExportFailedNoDeck => 'Select a deck to export.';

  @override
  String get loadDeckSettingsExportEmpty => 'No deck settings to export.';

  @override
  String loadDeckSettingsExported(Object count, Object path) {
    return 'Exported deck settings: $count\nFile: $path';
  }

  @override
  String loadDeckSettingsSavedToAppFiles(Object path) {
    return 'System save dialog is unavailable. Deck settings file saved to app files:\n$path';
  }

  @override
  String loadDeckSettingsExportError(Object error) {
    return 'Deck settings export error: $error';
  }

  @override
  String get loadImportDeckSettingsCancelled => 'Deck settings import cancelled: file not selected.';

  @override
  String get loadCouldNotReadDeckSettingsFile => 'Could not read deck settings file.';

  @override
  String loadDeckSettingsInvalidJson(Object error) {
    return 'Deck settings file is not valid JSON: $error';
  }

  @override
  String get loadDeckSettingsInvalidStructure => 'Deck settings file has invalid structure.';

  @override
  String get loadDeckSettingsUnsupportedFormat => 'Unsupported deck settings file format.';

  @override
  String loadDeckSettingsNothingImported(Object skipped) {
    return 'No valid deck settings imported. Skipped entries: $skipped.';
  }

  @override
  String loadDeckSettingsImported(Object imported, Object skipped) {
    return 'Deck settings imported: $imported. Skipped invalid entries: $skipped.';
  }

  @override
  String loadSyntheticOnyxEnabled(Object count) {
    return 'Catalog augmented with synthetic Fusion onyx results ($count cards)';
  }

  @override
  String loadSyntheticOnyxDisabled(Object count) {
    return 'Synthetic Fusion onyx results disabled ($count cards)';
  }

  @override
  String get tabShopSeasons => 'Shop seasons';

  @override
  String shopPackScheduleLoadError(Object error) {
    return 'Could not load shop schedule: $error';
  }

  @override
  String get shopPackInStoreNow => 'In shop now';

  @override
  String shopPackWindowDates(Object start, Object end) {
    return 'In shop: $start – $end';
  }

  @override
  String get shopPackCardLevel => 'Card level';

  @override
  String get shopPackCardsInPack => 'Cards in this pack';

  @override
  String get shopPackNoContents => 'No card list for this pack yet. Add names in shop_pack_contents.json.';

  @override
  String shopPackUnknownCard(Object name) {
    return 'Not in catalog: $name';
  }

  @override
  String get shopPackNoRotationScheduled => 'No matching slot in app rotation schedule';

  @override
  String shopPackWikiOpenFailed(Object url) {
    return 'Could not open wiki: $url';
  }

  @override
  String get shopPackOtherCategory => 'Other packs (not in app rotation)';

  @override
  String shopPackGoldCombo(Object card) {
    return 'Gold: $card';
  }

  @override
  String shopPackOnyxCombo(Object card) {
    return 'Onyx: $card';
  }

  @override
  String get eventsShopTitle => 'Shop';

  @override
  String get eventsShopSubtitle => 'Packs in shop';

  @override
  String get eventsArenaTitle => 'Arena';

  @override
  String get eventsArenaSubtitle => 'Arena shop';

  @override
  String get eventsPortalTitle => 'Portal';

  @override
  String get eventsPortalSubtitle => 'Portal rewards';
}
