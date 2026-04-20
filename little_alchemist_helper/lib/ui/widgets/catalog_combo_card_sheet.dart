import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/collection_store.dart';
import '../../l10n/l10n_ext.dart';
import '../../models/alchemy_card.dart';
import '../../models/catalog_owned_presence_filter.dart';
import '../../models/combo_lab_material_pick.dart';
import '../../models/combo_tier.dart';
import '../../models/owned_combo_entry.dart';
import '../../state/app_controller.dart';
import '../../util/card_instance_stats.dart';
import '../../util/card_sort.dart';
import 'card_sort_selector.dart';
import 'game_card_instance_row.dart';

bool _cardMatchesOwnedPresence(
  AlchemyCard card,
  AppController app,
  CatalogOwnedPresenceFilter filter,
) {
  switch (filter) {
    case CatalogOwnedPresenceFilter.all:
      return true;
    case CatalogOwnedPresenceFilter.inCollection:
      return app.catalogCardIdInCollection(card.cardId);
    case CatalogOwnedPresenceFilter.notInCollection:
      return !app.catalogCardIdInCollection(card.cardId);
  }
}

/// Bottom sheet: add a single combo-card instance to collection.
Future<void> showAddOneComboCardSheet({
  required BuildContext context,
  required AppController app,
  required VoidCallback onAdded,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (BuildContext sheetContext) {
      return _AddOneComboCardSheet(
        app: app,
        onAddedToCollection: () {
          Navigator.pop(sheetContext);
          onAdded();
        },
      );
    },
  );
}

/// Bottom sheet: bulk add cards.
Future<void> showBulkAddComboCardSheet({
  required BuildContext context,
  required AppController app,
  required VoidCallback onAdded,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (BuildContext sheetContext) {
      return _BulkAddComboCardSheet(
        app: app,
        onAdded: () {
          Navigator.pop(sheetContext);
          onAdded();
        },
      );
    },
  );
}

/// Single-card pick from catalog (short list by name).
Future<AlchemyCard?> showCatalogCardPickSheet({
  required BuildContext context,
  required AppController app,
  required String title,
  String? excludeCardId,
}) async {
  return showModalBottomSheet<AlchemyCard>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (BuildContext sheetContext) {
      return _CatalogCardPickSheet(
        app: app,
        title: title,
        excludeCardId: excludeCardId,
      );
    },
  );
}

/// Card and level picker for the Combo screen; instance tier is taken from catalog row.
Future<ComboLabMaterialPick?> showPickComboMaterialSheet({
  required BuildContext context,
  required AppController app,
  required String title,
  String? excludeCardId,
  ComboLabMaterialPick? initialPick,
}) async {
  return showModalBottomSheet<ComboLabMaterialPick>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (BuildContext sheetContext) {
      return _AddOneComboCardSheet(
        app: app,
        sheetTitle: title,
        excludeCardId: excludeCardId,
        pickContext: sheetContext,
        initialPick: initialPick,
      );
    },
  );
}

class _CatalogCardPickSheet extends StatefulWidget {
  const _CatalogCardPickSheet({
    required this.app,
    required this.title,
    this.excludeCardId,
  });

  final AppController app;
  final String title;
  final String? excludeCardId;

  @override
  State<_CatalogCardPickSheet> createState() => _CatalogCardPickSheetState();
}

class _CatalogCardPickSheetState extends State<_CatalogCardPickSheet> {
  late CatalogOwnedPresenceFilter _presenceFilter;
  late CardListSortMode _sortMode;
  late CardListSortDirection _sortDirection;

  InputDecoration _compactDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  @override
  void initState() {
    super.initState();
    _presenceFilter = widget.app.uiCatalogPresenceFilter;
    _sortMode = widget.app.uiCatalogListSortMode;
    _sortDirection = widget.app.uiCatalogListSortDirection;
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmImages());
  }

  void _warmImages() {
    final List<AlchemyCard> rows = _rows();
    widget.app.prefetchWikiImagesForCards(rows.take(100));
  }

  List<AlchemyCard> _rows() {
    final List<AlchemyCard> combo = widget.app.catalog.values
        .where((AlchemyCard c) => widget.app.cardCanFuse(c.cardId))
        .where(
          (AlchemyCard c) =>
              widget.excludeCardId == null || c.cardId != widget.excludeCardId,
        )
        .where(
          (AlchemyCard c) =>
              _cardMatchesOwnedPresence(c, widget.app, _presenceFilter),
        )
        .toList();
    sortAlchemyCards(combo, _sortMode, direction: _sortDirection);
    return combo;
  }

  @override
  Widget build(BuildContext context) {
    final List<AlchemyCard> rows = _rows();
    final double inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.7,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const <double>[0.7, 0.85, 0.95],
        builder: (BuildContext context, ScrollController sc) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child:
                          DropdownButtonFormField<CatalogOwnedPresenceFilter>(
                            value: _presenceFilter,
                            isExpanded: true,
                            decoration: _compactDropdownDecoration(
                              context.l10n.labelCollection,
                            ),
                            items: CatalogOwnedPresenceFilter.values.map((
                              CatalogOwnedPresenceFilter filter,
                            ) {
                              return DropdownMenuItem<
                                CatalogOwnedPresenceFilter
                              >(
                                value: filter,
                                child: Text(
                                  localizedPresenceLabel(context.l10n, filter),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (CatalogOwnedPresenceFilter? value) {
                              if (value == null) {
                                return;
                              }
                              setState(() => _presenceFilter = value);
                              widget.app.setUiCatalogPresenceFilter(value);
                              _warmImages();
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return CatalogOwnedPresenceFilter.values.map((
                                CatalogOwnedPresenceFilter filter,
                              ) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    localizedPresenceLabel(
                                      context.l10n,
                                      filter,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CardSortSelector(
                        mode: _sortMode,
                        direction: _sortDirection,
                        decoration: _compactDropdownDecoration(
                          context.l10n.labelSort,
                        ),
                        onModeChanged: (CardListSortMode value) {
                          setState(() => _sortMode = value);
                          widget.app.setUiCatalogListSortMode(value);
                          _warmImages();
                        },
                        onDirectionChanged: (CardListSortDirection direction) {
                          setState(() => _sortDirection = direction);
                          widget.app.setUiCatalogListSortDirection(direction);
                          _warmImages();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.catalogNoCards,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: sc,
                        itemCount: rows.length,
                        itemBuilder: (BuildContext context, int i) {
                          final AlchemyCard c = rows[i];
                          final ComboTier tier = comboTierFromCatalogRarity(
                            c.rarity,
                          );
                          final ({int attack, int defense}) scaled =
                              scaledCardInstanceStats(
                                card: c,
                                tier: tier,
                                level: OwnedComboEntry.minLevel,
                              );
                          return GameCardInstanceRow(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            card: c,
                            imageUrl: widget.app.cachedWikiImageUrlForCard(c),
                            loadImage: widget.app.loadCardImages,
                            frameTier: tier,
                            isFused: c.isFusedVariant,
                            title: c.displayName,
                            rarityLabel: localizedRarityLabel(
                              context.l10n,
                              c.rarity,
                            ),
                            attack: scaled.attack,
                            defense: scaled.defense,
                            abilityText: c.fusionAbility,
                            onTap: () => Navigator.pop(context, c),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Collection mode: calls [onAddedToCollection] after adding.
/// Combo mode: [pickContext] defines where to return [ComboLabMaterialPick] via [Navigator.pop].
class _AddOneComboCardSheet extends StatefulWidget {
  const _AddOneComboCardSheet({
    required this.app,
    this.onAddedToCollection,
    this.pickContext,
    this.sheetTitle,
    this.excludeCardId,
    this.initialPick,
  }) : assert(
         (pickContext != null) != (onAddedToCollection != null),
         'Exactly one mode required',
       );

  final AppController app;
  final VoidCallback? onAddedToCollection;
  final BuildContext? pickContext;
  final String? sheetTitle;
  final String? excludeCardId;
  final ComboLabMaterialPick? initialPick;

  bool get _isPickMode => pickContext != null;

  @override
  State<_AddOneComboCardSheet> createState() => _AddOneComboCardSheetState();
}

class _AddOneComboCardSheetState extends State<_AddOneComboCardSheet> {
  final TextEditingController _q = TextEditingController();
  String _query = '';
  String? _selectedCardId;
  int _level = OwnedComboEntry.minLevel;
  late CardListSortMode _catalogSort;
  late CardListSortDirection _catalogSortDirection;
  ComboTier? _catalogRarityFilter;
  late CatalogOwnedPresenceFilter _presenceFilter;

  /// Vertical scroll offset of catalog list ("Add one card" draft).
  double _listScrollPixels = 0.0;

  bool _scheduledAddOneListScrollRestore = false;
  bool _didApplyAddOneListScrollRestore = false;
  int _addOneListScrollRestoreAttempts = 0;

  @override
  void initState() {
    super.initState();
    _catalogSort = widget.app.uiCatalogListSortMode;
    _catalogSortDirection = widget.app.uiCatalogListSortDirection;
    _presenceFilter = widget.app.uiCatalogPresenceFilter;
    _catalogRarityFilter = widget.app.uiCatalogRarityTierFilter;
    final ComboLabMaterialPick? init = widget.initialPick;
    if (init != null && widget.app.catalog[init.cardId] != null) {
      _selectedCardId = init.cardId;
      _level = init.level.clamp(
        OwnedComboEntry.minLevel,
        OwnedComboEntry.maxLevel,
      );
    } else {
      _level = widget.app.lastAddComboLevel.clamp(
        OwnedComboEntry.minLevel,
        OwnedComboEntry.maxLevel,
      );
    }
    if (!widget._isPickMode) {
      final String? draftQ = widget.app.uiAddOneSheetSearchQuery;
      if (draftQ != null && draftQ.isNotEmpty) {
        _q.text = draftQ;
        _query = draftQ.trim().toLowerCase();
      }
      final String? draftId = widget.app.uiAddOneSheetSelectedCardId;
      if (draftId != null &&
          widget.app.catalog[draftId] != null &&
          widget.app.cardCanFuse(draftId) &&
          (widget.excludeCardId == null || draftId != widget.excludeCardId)) {
        _selectedCardId = draftId;
      }
      _listScrollPixels = widget.app.uiAddOneSheetListScrollOffset;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmListImages());
  }

  @override
  void dispose() {
    if (!widget._isPickMode) {
      unawaited(widget.app.persistLastComboLevel(_level));
      unawaited(
        widget.app.persistAddOneSheetDraft(
          searchQuery: _q.text,
          selectedCardId: _selectedCardId,
          listScrollOffset: _listScrollPixels,
        ),
      );
    }
    _q.dispose();
    super.dispose();
  }

  void _warmListImages() {
    final List<AlchemyCard> combo = _allFuseCards();
    widget.app.prefetchWikiImagesForCards(combo.take(120));
  }

  List<AlchemyCard> _allFuseCards() {
    return widget.app.catalog.values
        .where((AlchemyCard c) => widget.app.cardCanFuse(c.cardId))
        .where(
          (AlchemyCard c) =>
              widget.excludeCardId == null || c.cardId != widget.excludeCardId,
        )
        .toList();
  }

  bool _matchesCatalogRarity(AlchemyCard c) {
    if (_catalogRarityFilter == null) {
      return true;
    }
    return comboTierFromCatalogRarity(c.rarity) == _catalogRarityFilter;
  }

  AlchemyCard? _selectedCard() {
    if (_selectedCardId == null) {
      return null;
    }
    return widget.app.catalog[_selectedCardId!];
  }

  ComboTier _instanceTierForCatalogCard(AlchemyCard c) {
    final ComboTier fromData = comboTierFromCatalogRarity(c.rarity);
    return clampInstanceTierToCatalog(c, fromData);
  }

  InputDecoration _compactDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  Widget _buildCompactFiltersRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: DropdownButtonFormField<CatalogOwnedPresenceFilter>(
              value: _presenceFilter,
              isExpanded: true,
              decoration: _compactDropdownDecoration(
                context.l10n.labelCollection,
              ),
              items: CatalogOwnedPresenceFilter.values.map((
                CatalogOwnedPresenceFilter filter,
              ) {
                return DropdownMenuItem<CatalogOwnedPresenceFilter>(
                  value: filter,
                  child: Text(
                    localizedPresenceLabel(context.l10n, filter),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (CatalogOwnedPresenceFilter? value) {
                if (value == null) {
                  return;
                }
                setState(() => _presenceFilter = value);
                widget.app.setUiCatalogPresenceFilter(value);
                _warmListImages();
              },
              selectedItemBuilder: (BuildContext context) {
                return CatalogOwnedPresenceFilter.values.map((
                  CatalogOwnedPresenceFilter filter,
                ) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizedPresenceLabel(context.l10n, filter),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<ComboTier?>(
              value: _catalogRarityFilter,
              isExpanded: true,
              decoration: _compactDropdownDecoration(
                context.l10n.catalogRarityFilterTitle,
              ),
              items: <DropdownMenuItem<ComboTier?>>[
                DropdownMenuItem<ComboTier?>(
                  value: null,
                  child: Text(
                    context.l10n.labelAll,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ...ComboTier.values.map((ComboTier tier) {
                  return DropdownMenuItem<ComboTier?>(
                    value: tier,
                    child: Text(
                      localizedTierLabel(context.l10n, tier),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (ComboTier? value) {
                setState(() => _catalogRarityFilter = value);
                widget.app.setUiCatalogRarityTierFilter(value);
              },
              selectedItemBuilder: (BuildContext context) {
                return <ComboTier?>[null, ...ComboTier.values].map((
                  ComboTier? tier,
                ) {
                  final String label = tier == null
                      ? context.l10n.labelAll
                      : localizedTierLabel(context.l10n, tier);
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CardSortSelector(
              mode: _catalogSort,
              direction: _catalogSortDirection,
              decoration: _compactDropdownDecoration(context.l10n.labelSort),
              onModeChanged: (CardListSortMode value) {
                setState(() => _catalogSort = value);
                widget.app.setUiCatalogListSortMode(value);
              },
              onDirectionChanged: (CardListSortDirection direction) {
                setState(() => _catalogSortDirection = direction);
                widget.app.setUiCatalogListSortDirection(direction);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _tryRestoreAddOneListScroll(ScrollController sc, int itemCount) {
    if (!mounted || widget._isPickMode || _didApplyAddOneListScrollRestore) {
      return;
    }
    if (_addOneListScrollRestoreAttempts >= 16) {
      _didApplyAddOneListScrollRestore = true;
      return;
    }
    _addOneListScrollRestoreAttempts++;
    if (!sc.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryRestoreAddOneListScroll(sc, itemCount);
      });
      return;
    }
    final double maxExtent = sc.position.maxScrollExtent;
    if (itemCount > 0 && maxExtent <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryRestoreAddOneListScroll(sc, itemCount);
      });
      return;
    }
    final double target = _listScrollPixels.clamp(0.0, maxExtent);
    sc.jumpTo(target);
    _listScrollPixels = sc.offset;
    _didApplyAddOneListScrollRestore = true;
  }

  @override
  Widget build(BuildContext context) {
    final List<AlchemyCard> combo = _allFuseCards();
    sortAlchemyCards(combo, _catalogSort, direction: _catalogSortDirection);
    final List<AlchemyCard> filtered = combo.where((AlchemyCard c) {
      if (!_matchesCatalogRarity(c)) {
        return false;
      }
      if (!_cardMatchesOwnedPresence(c, widget.app, _presenceFilter)) {
        return false;
      }
      if (_query.isEmpty) {
        return true;
      }
      final String q = _query;
      return c.displayName.toLowerCase().contains(q) ||
          c.cardId.toLowerCase().contains(q);
    }).toList();

    final double inset = MediaQuery.viewInsetsOf(context).bottom;
    final AlchemyCard? selected = _selectedCard();

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.72,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const <double>[0.72, 0.85, 0.95],
        builder: (BuildContext context, ScrollController sc) {
          if (!widget._isPickMode && !_scheduledAddOneListScrollRestore) {
            _scheduledAddOneListScrollRestore = true;
            final int countForScroll = filtered.length;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              _tryRestoreAddOneListScroll(sc, countForScroll);
            });
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.sheetTitle ??
                      (widget._isPickMode
                          ? context.l10n.catalogPickCard
                          : context.l10n.collectionAddOne),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      context.l10n.catalogInstanceLevel(
                        localizedLevelLabel(context.l10n, _level),
                      ),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Slider(
                      value: _level.toDouble(),
                      min: OwnedComboEntry.minLevel.toDouble(),
                      max: OwnedComboEntry.maxLevel.toDouble(),
                      divisions:
                          OwnedComboEntry.maxLevel - OwnedComboEntry.minLevel,
                      label: localizedLevelLabel(context.l10n, _level),
                      onChanged: (double v) {
                        setState(() => _level = v.round());
                      },
                    ),
                    Text(
                      selected == null
                          ? context.l10n.catalogLevelWillBeSaved
                          : context.l10n.catalogFrameRarity(
                              localizedTierLabel(
                                context.l10n,
                                _instanceTierForCatalogCard(selected),
                              ),
                              localizedRarityLabel(
                                context.l10n,
                                selected.rarity,
                              ),
                            ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _q,
                  decoration: InputDecoration(
                    hintText: context.l10n.catalogSearchHint,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              _buildCompactFiltersRow(context),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification n) {
                    if (widget._isPickMode) {
                      return false;
                    }
                    if (n.metrics.axis == Axis.vertical) {
                      _listScrollPixels = n.metrics.pixels;
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: sc,
                    itemCount: filtered.length,
                    itemBuilder: (BuildContext context, int i) {
                      final AlchemyCard c = filtered[i];
                      final bool sel = _selectedCardId == c.cardId;
                      final ComboTier tier = comboTierFromCatalogRarity(
                        c.rarity,
                      );
                      final ({int attack, int defense}) scaled =
                          scaledCardInstanceStats(
                            card: c,
                            tier: tier,
                            level: _level,
                          );
                      return GameCardInstanceRow(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        selected: sel,
                        card: c,
                        imageUrl: widget.app.cachedWikiImageUrlForCard(c),
                        loadImage: widget.app.loadCardImages,
                        frameTier: tier,
                        isFused: c.isFusedVariant,
                        title: c.displayName,
                        rarityLabel: localizedRarityLabel(
                          context.l10n,
                          c.rarity,
                        ),
                        attack: scaled.attack,
                        defense: scaled.defense,
                        abilityText: c.fusionAbility,
                        onTap: () => setState(() {
                          _selectedCardId = c.cardId;
                          if (c.isFusedVariant) {
                            _level = OwnedComboEntry.fusedLevel;
                          }
                        }),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _selectedCardId == null
                      ? null
                      : () async {
                          final AlchemyCard? c = selected;
                          if (c == null) {
                            return;
                          }
                          final ComboTier tier = _instanceTierForCatalogCard(c);
                          if (widget._isPickMode) {
                            await widget.app.persistLastComboLevel(_level);
                            if (!mounted) {
                              return;
                            }
                            Navigator.pop(
                              widget.pickContext!,
                              ComboLabMaterialPick(
                                cardId: _selectedCardId!,
                                tier: tier,
                                level: _level,
                              ),
                            );
                            return;
                          }
                          await widget.app.addOwnedComboEntry(
                            cardId: _selectedCardId!,
                            tier: tier,
                            level: _level,
                          );
                          widget.onAddedToCollection!();
                        },
                  child: Text(
                    widget._isPickMode
                        ? context.l10n.actionDone
                        : context.l10n.collectionAddToCollection,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BulkAddComboCardSheet extends StatefulWidget {
  const _BulkAddComboCardSheet({required this.app, required this.onAdded});

  final AppController app;
  final VoidCallback onAdded;

  @override
  State<_BulkAddComboCardSheet> createState() => _BulkAddComboCardSheetState();
}

class _BulkAddComboCardSheetState extends State<_BulkAddComboCardSheet> {
  int _bulkCopies = 3;
  int _bulkLevel = OwnedComboEntry.fusedLevel;
  late CatalogOwnedPresenceFilter _presenceFilter;
  ComboTier? _bulkCatalogRarityFilter;
  bool _allowExcessPerDeckGroup = false;

  @override
  void initState() {
    super.initState();
    _presenceFilter = widget.app.uiCatalogPresenceFilter;
    _bulkCatalogRarityFilter = widget.app.uiCatalogRarityTierFilter;
  }

  bool _matchesBulkCatalogRarity(AlchemyCard c) {
    if (_bulkCatalogRarityFilter == null) {
      return true;
    }
    return comboTierFromCatalogRarity(c.rarity) == _bulkCatalogRarityFilter;
  }

  List<AlchemyCard> _fuseCardsForBulk() {
    return widget.app.catalog.values
        .where((AlchemyCard c) => widget.app.cardCanFuse(c.cardId))
        .where(
          (AlchemyCard c) =>
              _cardMatchesOwnedPresence(c, widget.app, _presenceFilter),
        )
        .where(_matchesBulkCatalogRarity)
        .toList();
  }

  int _fuseCardCount() {
    return _fuseCardsForBulk().length;
  }

  @override
  Widget build(BuildContext context) {
    final int kindCount = _fuseCardCount();
    final double inset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.35,
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController sc) {
          return ListView(
            controller: sc,
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                context.l10n.collectionAddMany,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.catalogBulkIntro(kindCount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _CatalogPresenceFilterChips(
                value: _presenceFilter,
                onChanged: (CatalogOwnedPresenceFilter v) {
                  setState(() => _presenceFilter = v);
                  widget.app.setUiCatalogPresenceFilter(v);
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.catalogRarityFilterTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  FilterChip(
                    label: Text(context.l10n.labelAll),
                    selected: _bulkCatalogRarityFilter == null,
                    onSelected: (_) {
                      setState(() => _bulkCatalogRarityFilter = null);
                      widget.app.setUiCatalogRarityTierFilter(null);
                    },
                  ),
                  for (final ComboTier t in ComboTier.values)
                    FilterChip(
                      label: Text(localizedTierLabel(context.l10n, t)),
                      selected: _bulkCatalogRarityFilter == t,
                      onSelected: (_) {
                        setState(() => _bulkCatalogRarityFilter = t);
                        widget.app.setUiCatalogRarityTierFilter(t);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _allowExcessPerDeckGroup,
                onChanged: (bool? v) {
                  setState(() {
                    _allowExcessPerDeckGroup = v ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  context.l10n.catalogAllowOverLimit(
                    CollectionStore.maxCopiesPerDeckGroupName,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.catalogOverLimitHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: context.l10n.catalogCopiesPerCard,
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _bulkCopies,
                    items: <DropdownMenuItem<int>>[
                      for (int n = 1; n <= 3; n++)
                        DropdownMenuItem<int>(value: n, child: Text('$n')),
                    ],
                    onChanged: (int? v) {
                      if (v != null) {
                        setState(() => _bulkCopies = v);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.catalogAllNewLevel(
                  localizedLevelLabel(context.l10n, _bulkLevel),
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _bulkLevel.toDouble(),
                min: OwnedComboEntry.minLevel.toDouble(),
                max: OwnedComboEntry.maxLevel.toDouble(),
                divisions: OwnedComboEntry.maxLevel - OwnedComboEntry.minLevel,
                label: localizedLevelLabel(context.l10n, _bulkLevel),
                onChanged: (double v) {
                  setState(() => _bulkLevel = v.round());
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: kindCount < 1
                    ? null
                    : () async {
                        final int total = kindCount * _bulkCopies;
                        final String limitLine = _allowExcessPerDeckGroup
                            ? context.l10n.catalogLimitNotApplied
                            : context.l10n.catalogLimitAppliedHint(
                                CollectionStore.maxCopiesPerDeckGroupName,
                              );
                        final bool? ok = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext ctx) => AlertDialog(
                            title: Text(context.l10n.catalogBulkAddTitle),
                            content: Text(
                              context.l10n.catalogBulkAddConfirm(
                                total,
                                kindCount,
                                _bulkCopies,
                                localizedLevelLabel(context.l10n, _bulkLevel),
                                limitLine,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(context.l10n.actionCancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(context.l10n.actionDone),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          final List<String> ids = _fuseCardsForBulk()
                              .map((AlchemyCard c) => c.cardId)
                              .toList();
                          await widget.app.bulkAddOwnedComboEntries(
                            cardIds: ids,
                            copiesPerCard: _bulkCopies,
                            level: _bulkLevel,
                            allowExcessPerDeckGroup: _allowExcessPerDeckGroup,
                          );
                          widget.onAdded();
                        }
                      },
                icon: const Icon(Icons.library_add),
                label: Text(context.l10n.catalogAddAll(kindCount)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogPresenceFilterChips extends StatelessWidget {
  const _CatalogPresenceFilterChips({
    required this.value,
    required this.onChanged,
  });

  final CatalogOwnedPresenceFilter value;
  final ValueChanged<CatalogOwnedPresenceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.l10n.labelCollection,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: CatalogOwnedPresenceFilter.values.map((
            CatalogOwnedPresenceFilter f,
          ) {
            return FilterChip(
              label: Text(localizedPresenceLabel(context.l10n, f)),
              selected: value == f,
              onSelected: (_) => onChanged(f),
            );
          }).toList(),
        ),
      ],
    );
  }
}
