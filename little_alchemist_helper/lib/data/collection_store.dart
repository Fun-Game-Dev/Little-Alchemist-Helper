import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alchemy_card.dart';
import '../models/combo_tier.dart';
import '../util/catalog_fusion.dart';
import '../models/catalog_owned_presence_filter.dart';
import '../models/deck_profile.dart';
import '../models/owned_combo_entry.dart';
import '../util/card_sort.dart';

/// Local storage for combo-card instances, deck profiles, and shared settings.
class CollectionStore {
  CollectionStore(this._prefs);

  static const String _inventoryV3Key = 'combo_inventory_v3';
  static const String _decksKey = 'deck_profiles_v1';
  static const String _selectedDeckIdKey = 'selected_deck_id_v1';
  static const String _catalogOverlayPathKey = 'user_catalog_overlay_path_v1';
  static const String _loadImagesKey = 'load_card_images_v1';
  static const String _wikiImageUrlsKey = 'wiki_image_urls_v1';
  static const String _lastAddComboLevelKey = 'last_add_combo_level_v1';
  static const String _augmentSyntheticOnyxCatalogKey =
      'augment_synthetic_onyx_catalog_v1';

  /// Sorting mode for collection/deck lists (index of [CardListSortMode]).
  static const String _uiCardListSortKey = 'ui_card_list_sort_v1';
  static const String _uiCardListSortAscendingKey = 'ui_card_list_sort_asc_v1';

  /// Collapse duplicate entries on collection and deck screens.
  static const String _uiCollapseDuplicatesKey = 'ui_collapse_duplicates_v1';

  /// "Owned" filter in catalog sheets (index of [CatalogOwnedPresenceFilter]).
  static const String _uiCatalogPresenceKey = 'ui_catalog_presence_v1';

  static const String _uiCatalogRarityTierKeyV2 = 'ui_catalog_rarity_tier_v2';

  /// List sorting in catalog forms (index of [CardListSortMode]).
  static const String _uiCatalogListSortKey = 'ui_catalog_list_sort_v1';
  static const String _uiCatalogListSortAscendingKey =
      'ui_catalog_list_sort_asc_v1';

  /// "Add one card" form draft: search query.
  static const String _addOneSheetQueryKey = 'add_one_sheet_query_v1';

  /// "Add one card" form draft: selected catalog card ID.
  static const String _addOneSheetSelectedCardIdKey =
      'add_one_sheet_selected_card_v1';

  /// Vertical scroll offset of catalog list in the "Add one card" form.
  static const String _addOneSheetListScrollOffsetKey =
      'add_one_sheet_list_scroll_offset_v1';

  static const int _addOneSheetQueryMaxLength = 256;

  /// Max copies per in-game card name ([AlchemyCard.deckGroupKey]) in collection and deck.
  static const int maxCopiesPerDeckGroupName = 3;

  final SharedPreferences _prefs;
  static final Random _rng = Random();

  static Future<CollectionStore> open() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    return CollectionStore(p);
  }

  static String createEntryId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(0x7fffffff)}';
  }

  List<OwnedComboEntry> readOwnedComboEntries({
    required Map<String, AlchemyCard> catalog,
  }) {
    final List<OwnedComboEntry> v3 = _readInventoryV3List();
    return _sanitizeEntries(v3, catalog);
  }

  Future<void> writeOwnedComboEntries(List<OwnedComboEntry> entries) {
    final List<Map<String, Object?>> raw = <Map<String, Object?>>[];
    for (final OwnedComboEntry e in entries) {
      raw.add(e.toJson());
    }
    return _prefs.setString(_inventoryV3Key, jsonEncode(raw));
  }

  List<DeckProfile> readDeckProfiles() {
    final String? raw = _prefs.getString(_decksKey);
    if (raw == null || raw.isEmpty) {
      return <DeckProfile>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <DeckProfile>[];
      }
      final List<DeckProfile> out = <DeckProfile>[];
      for (final Object? e in decoded) {
        if (e is Map) {
          final Map<String, Object?> m = e.map(
            (Object? k, Object? v) =>
                MapEntry<String, Object?>(k.toString(), v),
          );
          final DeckProfile? p = DeckProfile.fromJson(m);
          if (p != null) {
            out.add(p);
          }
        }
      }
      return out;
    } on Object catch (e, st) {
      debugPrint('readDeckProfiles: $e\n$st');
      return <DeckProfile>[];
    }
  }

  /// Returns false if write to SharedPreferences fails.
  Future<bool> writeDeckProfiles(List<DeckProfile> profiles) async {
    try {
      final List<Map<String, Object?>> raw = <Map<String, Object?>>[
        for (final DeckProfile p in profiles) p.toJson(),
      ];
      final bool ok = await _prefs.setString(_decksKey, jsonEncode(raw));
      if (!ok) {
        debugPrint('writeDeckProfiles: setString вернул false');
      }
      return ok;
    } on Object catch (e, st) {
      debugPrint('writeDeckProfiles: $e\n$st');
      return false;
    }
  }

  String? readSelectedDeckId() {
    final String? id = _prefs.getString(_selectedDeckIdKey);
    if (id == null || id.isEmpty) {
      return null;
    }
    return id;
  }

  Future<void> writeSelectedDeckId(String? id) {
    if (id == null || id.isEmpty) {
      return _prefs.remove(_selectedDeckIdKey);
    }
    return _prefs.setString(_selectedDeckIdKey, id);
  }

  String? readUserCatalogOverlayPath() {
    return _prefs.getString(_catalogOverlayPathKey);
  }

  Future<void> writeUserCatalogOverlayPath(String? path) {
    if (path == null || path.isEmpty) {
      return _prefs.remove(_catalogOverlayPathKey);
    }
    return _prefs.setString(_catalogOverlayPathKey, path);
  }

  bool readLoadCardImages() {
    return _prefs.getBool(_loadImagesKey) ?? false;
  }

  Future<void> writeLoadCardImages(bool value) {
    return _prefs.setBool(_loadImagesKey, value);
  }

  Map<String, String?> readWikiImageUrlMap() {
    final String? raw = _prefs.getString(_wikiImageUrlsKey);
    if (raw == null || raw.isEmpty) {
      return <String, String?>{};
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, String?>{};
      }
      final Map<String, String?> out = <String, String?>{};
      decoded.forEach((Object? k, Object? v) {
        final String key = k.toString();
        if (v == null) {
          out[key] = null;
        } else if (v is String) {
          out[key] = v;
        }
      });
      return out;
    } on Object {
      return <String, String?>{};
    }
  }

  Future<void> writeWikiImageUrlMap(Map<String, String?> urls) {
    return _prefs.setString(_wikiImageUrlsKey, jsonEncode(urls));
  }

  /// Last selected instance level in the "Add one card" form.
  int readLastAddComboLevel() {
    final int? v = _prefs.getInt(_lastAddComboLevelKey);
    if (v == null) {
      return OwnedComboEntry.minLevel;
    }
    return v.clamp(OwnedComboEntry.minLevel, OwnedComboEntry.maxLevel);
  }

  Future<void> writeLastAddComboLevel(int level) {
    final int clamped = level.clamp(
      OwnedComboEntry.minLevel,
      OwnedComboEntry.maxLevel,
    );
    return _prefs.setInt(_lastAddComboLevelKey, clamped);
  }

  /// Extend catalog with onyx materials (combo-card copies) and, if file exists, "2 onyx" outcomes (see [assets/fusion_onyx_stats.json]).
  bool readAugmentSyntheticOnyxCatalog() {
    return _prefs.getBool(_augmentSyntheticOnyxCatalogKey) ?? true;
  }

  Future<void> writeAugmentSyntheticOnyxCatalog(bool value) {
    return _prefs.setBool(_augmentSyntheticOnyxCatalogKey, value);
  }

  CardListSortMode readUiCardListSortMode() {
    final int? v = _prefs.getInt(_uiCardListSortKey);
    if (v == null) {
      return CardListSortMode.byPower;
    }
    return cardListSortModeFromStorageIndex(v);
  }

  Future<void> writeUiCardListSortMode(CardListSortMode mode) {
    return _prefs.setInt(_uiCardListSortKey, mode.index);
  }

  CardListSortDirection readUiCardListSortDirection() {
    final bool? v = _prefs.getBool(_uiCardListSortAscendingKey);
    return v == false
        ? CardListSortDirection.descending
        : CardListSortDirection.ascending;
  }

  Future<void> writeUiCardListSortDirection(CardListSortDirection direction) {
    return _prefs.setBool(
      _uiCardListSortAscendingKey,
      direction == CardListSortDirection.ascending,
    );
  }

  bool readUiCollapseDuplicates() {
    return _prefs.getBool(_uiCollapseDuplicatesKey) ?? false;
  }

  Future<void> writeUiCollapseDuplicates(bool value) {
    return _prefs.setBool(_uiCollapseDuplicatesKey, value);
  }

  CatalogOwnedPresenceFilter readUiCatalogPresenceFilter() {
    final int? v = _prefs.getInt(_uiCatalogPresenceKey);
    if (v == null) {
      return CatalogOwnedPresenceFilter.all;
    }
    if (v < 0 || v >= CatalogOwnedPresenceFilter.values.length) {
      return CatalogOwnedPresenceFilter.all;
    }
    return CatalogOwnedPresenceFilter.values[v];
  }

  Future<void> writeUiCatalogPresenceFilter(CatalogOwnedPresenceFilter f) {
    return _prefs.setInt(_uiCatalogPresenceKey, f.index);
  }

  /// `null` means the "All" filter for data rarity.
  ComboTier? readUiCatalogRarityTierFilter() {
    final String? s = _prefs.getString(_uiCatalogRarityTierKeyV2);
    if (s == null || s.isEmpty) {
      return null;
    }
    return comboTierFromStorageName(s);
  }

  Future<void> writeUiCatalogRarityTierFilter(ComboTier? tier) async {
    if (tier == null) {
      await _prefs.remove(_uiCatalogRarityTierKeyV2);
    } else {
      await _prefs.setString(_uiCatalogRarityTierKeyV2, tier.nameForStorage);
    }
  }

  CardListSortMode readUiCatalogListSortMode() {
    final int? v = _prefs.getInt(_uiCatalogListSortKey);
    if (v == null) {
      return CardListSortMode.byName;
    }
    return cardListSortModeFromStorageIndex(v);
  }

  Future<void> writeUiCatalogListSortMode(CardListSortMode mode) {
    return _prefs.setInt(_uiCatalogListSortKey, mode.index);
  }

  CardListSortDirection readUiCatalogListSortDirection() {
    final bool? v = _prefs.getBool(_uiCatalogListSortAscendingKey);
    return v == false
        ? CardListSortDirection.descending
        : CardListSortDirection.ascending;
  }

  Future<void> writeUiCatalogListSortDirection(
    CardListSortDirection direction,
  ) {
    return _prefs.setBool(
      _uiCatalogListSortAscendingKey,
      direction == CardListSortDirection.ascending,
    );
  }

  /// Search query in the "Add one card" form (last session).
  String? readAddOneSheetSearchQuery() {
    final String? raw = _prefs.getString(_addOneSheetQueryKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    if (raw.length > _addOneSheetQueryMaxLength) {
      return raw.substring(0, _addOneSheetQueryMaxLength);
    }
    return raw;
  }

  Future<void> writeAddOneSheetSearchQuery(String? query) {
    if (query == null || query.isEmpty) {
      return _prefs.remove(_addOneSheetQueryKey);
    }
    final String t = query.length > _addOneSheetQueryMaxLength
        ? query.substring(0, _addOneSheetQueryMaxLength)
        : query;
    return _prefs.setString(_addOneSheetQueryKey, t);
  }

  String? readAddOneSheetSelectedCardId() {
    final String? id = _prefs.getString(_addOneSheetSelectedCardIdKey);
    if (id == null || id.isEmpty) {
      return null;
    }
    return id;
  }

  Future<void> writeAddOneSheetSelectedCardId(String? cardId) {
    if (cardId == null || cardId.isEmpty) {
      return _prefs.remove(_addOneSheetSelectedCardIdKey);
    }
    return _prefs.setString(_addOneSheetSelectedCardIdKey, cardId);
  }

  double readAddOneSheetListScrollOffset() {
    return _prefs.getDouble(_addOneSheetListScrollOffsetKey) ?? 0.0;
  }

  Future<void> writeAddOneSheetListScrollOffset(double pixels) {
    final double v = pixels.clamp(0.0, 1e7);
    if (v <= 0) {
      return _prefs.remove(_addOneSheetListScrollOffsetKey);
    }
    return _prefs.setDouble(_addOneSheetListScrollOffsetKey, v);
  }

  List<OwnedComboEntry> _readInventoryV3List() {
    final String? raw = _prefs.getString(_inventoryV3Key);
    if (raw == null || raw.isEmpty) {
      return <OwnedComboEntry>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <OwnedComboEntry>[];
      }
      final List<OwnedComboEntry> out = <OwnedComboEntry>[];
      for (final Object? e in decoded) {
        if (e is Map) {
          final Map<String, Object?> m = e.map(
            (Object? k, Object? v) =>
                MapEntry<String, Object?>(k.toString(), v),
          );
          final OwnedComboEntry? entry = OwnedComboEntry.fromJson(m);
          if (entry != null) {
            out.add(entry);
          }
        }
      }
      return out;
    } on Object {
      return <OwnedComboEntry>[];
    }
  }

  static List<OwnedComboEntry> _sanitizeEntries(
    List<OwnedComboEntry> raw,
    Map<String, AlchemyCard> catalog,
  ) {
    final Set<String> fusionParticipants = fusionParticipantCardIds(catalog);
    final List<OwnedComboEntry> out = <OwnedComboEntry>[];
    for (final OwnedComboEntry e in raw) {
      final AlchemyCard? c = catalog[e.cardId];
      if (c == null || !fusionParticipants.contains(e.cardId)) {
        continue;
      }
      ComboTier tier = e.tier;
      if (tier == ComboTier.onyx &&
          maxInstanceTierForCatalogCard(c) == ComboTier.diamond) {
        tier = ComboTier.diamond;
      }
      tier = clampInstanceTierToCatalog(c, tier);
      out.add(
        e.copyWith(
          tier: tier,
          level: e.level.clamp(
            OwnedComboEntry.minLevel,
            OwnedComboEntry.maxLevel,
          ),
        ),
      );
    }
    return out;
  }
}
