import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../data/card_catalog_parser.dart';
import '../data/catalog_json_merge.dart';
import '../data/collection_store.dart';
import '../data/excel_combo_base_builder.dart';
import '../data/fusion_onyx_sheet.dart';
import '../data/onyx_wiki_allowlist.dart';
import '../data/shop_pack_models.dart';
import '../data/special_pack_models.dart';
import '../data/synthetic_onyx_catalog_augment.dart';
import '../models/alchemy_card.dart';
import '../models/catalog_owned_presence_filter.dart';
import '../models/combo_tier.dart';
import '../models/deck_profile.dart';
import '../models/deck_result.dart';
import '../models/deck_settings.dart';
import '../models/deck_focus_preset.dart';
import '../models/combo_lab_material_pick.dart';
import '../models/owned_combo_entry.dart';
import '../services/deck_optimizer.dart';
import '../services/card_image_cache.dart';
import '../services/wiki_image_url_service.dart';
import '../util/card_sort.dart';
import '../util/catalog_fusion.dart';
import '../util/io_helper.dart';

part 'app_controller_catalog.dart';
part 'app_controller_collection.dart';
part 'app_controller_decks.dart';
part 'app_controller_export_import.dart';
part 'app_controller_preferences.dart';

@immutable
class CollectionTextImportResult {
  const CollectionTextImportResult({
    required this.importedCount,
    required this.skippedInvalidLines,
    required this.notFoundCardNames,
  });

  final int importedCount;
  final int skippedInvalidLines;
  final List<String> notFoundCardNames;
}

@immutable
class DeckSettingsImportResult {
  const DeckSettingsImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  final int importedCount;
  final int skippedCount;
}

class AppController extends ChangeNotifier {
  AppController._(this._store, this._wiki, this._optimizer);

  final CollectionStore _store;
  final WikiImageUrlService _wiki;
  final DeckOptimizer _optimizer;
  final CardCatalogParser _parser = const CardCatalogParser();

  Map<String, AlchemyCard> _catalog = <String, AlchemyCard>{};
  Set<String> _fusionParticipantIds = <String>{};
  List<OwnedComboEntry> _ownedComboEntries = <OwnedComboEntry>[];
  List<DeckProfile> _deckProfiles = <DeckProfile>[];
  String? _selectedDeckId;
  bool _loadCardImages = true;
  String? _userCatalogOverlayPath;
  String? _loadMessage;
  String _appVersion = '-';
  String _appBuildNumber = '-';
  DeckOptimizationResult? _lastDeckResult;
  FusionOnyxSheet? _fusionOnyxSheet;
  ComboLabMaterialPick? _comboLabPickA;
  ComboLabMaterialPick? _comboLabPickB;
  int _lastAddComboLevel = OwnedComboEntry.minLevel;
  bool _augmentSyntheticOnyxCatalog = true;
  CardListSortMode _uiCardListSortMode = CardListSortMode.byPower;
  CardListSortDirection _uiCardListSortDirection =
      CardListSortDirection.descending;
  bool _uiCollapseDuplicates = false;
  CatalogOwnedPresenceFilter _uiCatalogPresenceFilter =
      CatalogOwnedPresenceFilter.all;
  ComboTier? _uiCatalogRarityTierFilter;
  CardListSortMode _uiCatalogListSortMode = CardListSortMode.byName;
  CardListSortDirection _uiCatalogListSortDirection =
      CardListSortDirection.ascending;
  String? _uiAddOneSheetSearchQuery;
  String? _uiAddOneSheetSelectedCardId;
  double _uiAddOneSheetListScrollOffset = 0.0;
  Locale _locale = _supportedLocale(PlatformDispatcher.instance.locale);
  AppLocalizations _l10n = lookupAppLocalizations(
    _supportedLocale(PlatformDispatcher.instance.locale),
  );

  static Locale _supportedLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return const Locale('ru');
      case 'es':
        return const Locale('es');
      default:
        return const Locale('en');
    }
  }

  void setLocale(Locale locale) {
    final Locale next = _supportedLocale(locale);
    if (next == _locale) {
      return;
    }
    _locale = next;
    _l10n = lookupAppLocalizations(next);
  }

  void _logUiError(String context, Object error, StackTrace stackTrace) {
    debugPrint('$context: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  Map<String, AlchemyCard> get catalog => _catalog;
  List<OwnedComboEntry> get ownedComboEntries =>
      List<OwnedComboEntry>.unmodifiable(_ownedComboEntries);
  List<DeckProfile> get deckProfiles =>
      List<DeckProfile>.unmodifiable(_deckProfiles);
  String? get selectedDeckId => _selectedDeckId;

  DeckProfile? get selectedDeckProfile {
    final String? id = _selectedDeckId;
    if (id == null) {
      return null;
    }
    for (final DeckProfile p in _deckProfiles) {
      if (p.id == id) {
        return p;
      }
    }
    return null;
  }

  bool get loadCardImages => _loadCardImages;
  String? get loadMessage => _loadMessage;
  String get appVersion => _appVersion;
  String get appBuildNumber => _appBuildNumber;
  DeckOptimizationResult? get lastDeckResult => _lastDeckResult;
  WikiImageUrlService get wikiImageService => _wiki;

  ComboLabMaterialPick? get comboLabPickA => _comboLabPickA;
  ComboLabMaterialPick? get comboLabPickB => _comboLabPickB;

  /// Default level for "Add one card" (last saved selection).
  int get lastAddComboLevel => _lastAddComboLevel;

  /// List sorting mode on collection and deck screens.
  CardListSortMode get uiCardListSortMode => _uiCardListSortMode;
  CardListSortDirection get uiCardListSortDirection => _uiCardListSortDirection;

  /// Collapse duplicate entries on collection and deck screens.
  bool get uiCollapseDuplicates => _uiCollapseDuplicates;

  /// Ownership filter in catalog sheets.
  CatalogOwnedPresenceFilter get uiCatalogPresenceFilter =>
      _uiCatalogPresenceFilter;

  /// Data rarity filter for catalog forms (`null` means all).
  ComboTier? get uiCatalogRarityTierFilter => _uiCatalogRarityTierFilter;

  /// Card-list sorting in catalog forms.
  CardListSortMode get uiCatalogListSortMode => _uiCatalogListSortMode;
  CardListSortDirection get uiCatalogListSortDirection =>
      _uiCatalogListSortDirection;

  /// Last search query in "Add one card" form.
  String? get uiAddOneSheetSearchQuery => _uiAddOneSheetSearchQuery;

  /// Last selected card in "Add one card" form.
  String? get uiAddOneSheetSelectedCardId => _uiAddOneSheetSelectedCardId;

  /// Catalog list scroll offset in "Add one card" form.
  double get uiAddOneSheetListScrollOffset => _uiAddOneSheetListScrollOffset;

  bool get augmentSyntheticOnyxCatalog => _augmentSyntheticOnyxCatalog;

  FusionOnyxSheet? get fusionOnyxSheet => _fusionOnyxSheet;

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

  /// Persists the last selected instance level (combo form / add form).
  Future<void> persistLastComboLevel(int level) async {
    final int lvl = level.clamp(
      OwnedComboEntry.minLevel,
      OwnedComboEntry.maxLevel,
    );
    _lastAddComboLevel = lvl;
    await _store.writeLastAddComboLevel(lvl);
    notifyListeners();
  }

  /// Persists "Add one card" draft (search, selected card, scroll).
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

  /// Cached preview URL (after [prefetchWikiImagesForCards] or past requests).
  String? cachedWikiImageUrl(
    String displayName, {
    bool isOnyxTier = false,
  }) {
    if (!_loadCardImages) {
      return null;
    }
    return _wiki.cachedUrlForDisplayName(
      displayName,
      isOnyxTier: isOnyxTier,
    );
  }

  /// Same as [cachedWikiImageUrl] with onyx tier derived from [card.rarity].
  String? cachedWikiImageUrlForCard(AlchemyCard card) {
    if (!_loadCardImages) {
      return null;
    }
    return _wiki.cachedUrlForDisplayName(
      card.displayName,
      isOnyxTier: comboTierFromCatalogRarity(card.rarity) == ComboTier.onyx,
    );
  }

  Future<void> prefetchWikiImagesForCards(Iterable<AlchemyCard?> cards) async {
    if (!_loadCardImages) {
      return;
    }
    final Set<String> seen = <String>{};
    final List<({String displayName, bool isOnyxTier})> keys =
        <({String displayName, bool isOnyxTier})>[];
    for (final AlchemyCard? c in cards) {
      if (c == null) {
        continue;
      }
      final String t = c.displayName.trim();
      if (t.isEmpty) {
        continue;
      }
      final bool isOnyx = comboTierFromCatalogRarity(c.rarity) == ComboTier.onyx;
      final String dedupe = '$t\u001E$isOnyx';
      if (seen.contains(dedupe)) {
        continue;
      }
      seen.add(dedupe);
      keys.add((displayName: c.displayName, isOnyxTier: isOnyx));
    }
    if (keys.isEmpty) {
      return;
    }
    await _wiki.resolveBatch(keys);
    notifyListeners();
  }

  int get catalogCount => _catalog.length;

  /// Whether the card participates in at least one fusion pair in current catalog.
  bool cardCanFuse(String cardId) => _fusionParticipantIds.contains(cardId);

  /// Whether collection contains at least one instance of this catalog card.
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

  /// [AlchemyCard.deckGroupKey] groups with instance count > 3.
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

  static Future<AppController> bootstrap() async {
    return bootstrapWithProgress();
  }

  static Future<AppController> bootstrapWithProgress({
    void Function(String message, double progress)? onProgress,
  }) async {
    final AppLocalizations bootstrapL10n = lookupAppLocalizations(
      _supportedLocale(PlatformDispatcher.instance.locale),
    );
    void report(String message, double progress) {
      onProgress?.call(message, progress.clamp(0.0, 1.0));
    }

    report(bootstrapL10n.bootstrapInitializing, 0.05);
    final CollectionStore store = await CollectionStore.open();
    report(bootstrapL10n.bootstrapPreparingImageCache, 0.15);
    final Map<String, String?> wikiSeed = store.readWikiImageUrlMap();
    final AppController c = AppController._(
      store,
      WikiImageUrlService(
        seededUrls: wikiSeed,
        persistUrls: store.writeWikiImageUrlMap,
      ),
      const DeckOptimizer(),
    );
    report(bootstrapL10n.bootstrapLoadingSettings, 0.25);
    await c._hydratePrefsOnly();
    report(bootstrapL10n.bootstrapLoadingDecks, 0.35);
    await c._hydrateDecksOnly();
    await c._finishBootstrap(onProgress: report);
    report(bootstrapL10n.bootstrapDone, 1.0);
    return c;
  }

  Future<void> _finishBootstrap({
    required void Function(String message, double progress) onProgress,
  }) async {
    onProgress(_l10n.bootstrapReadingAppVersion, 0.45);
    await _hydrateAppInfo();
    onProgress(_l10n.bootstrapBuildingCatalog, 0.55);
    await _loadInitialCatalog(
      onProgress: (String message, double partProgress) {
        final double normalized = 0.55 + (partProgress * 0.35);
        onProgress(message, normalized);
      },
    );
    onProgress(_l10n.bootstrapRecomputingDeck, 0.95);
    recomputeBestDeck();
    notifyListeners();
  }

  Future<void> _hydrateAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version.trim().isEmpty
          ? '-'
          : packageInfo.version.trim();
      _appBuildNumber = packageInfo.buildNumber.trim().isEmpty
          ? '-'
          : packageInfo.buildNumber.trim();
    } on Object catch (_) {
      _appVersion = '-';
      _appBuildNumber = '-';
    }
  }

  @override
  void dispose() {
    _wiki.dispose();
    super.dispose();
  }
}
