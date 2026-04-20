import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/collection_store.dart';
import '../../l10n/l10n_ext.dart';
import '../../models/alchemy_card.dart';
import '../../models/combo_tier.dart';
import '../../models/owned_combo_entry.dart';
import '../../state/app_controller.dart';
import '../../util/card_list_groups.dart';
import '../../util/card_instance_stats.dart';
import '../../util/card_sort.dart';
import '../widgets/catalog_combo_card_sheet.dart';
import '../widgets/card_sort_selector.dart';
import '../widgets/duplicate_grouping_checkbox.dart';
import '../widgets/game_card_instance_row.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  Timer? _resolveTimer;

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scheduleImageResolve(),
    );
  }

  @override
  void dispose() {
    _resolveTimer?.cancel();
    super.dispose();
  }

  void _scheduleImageResolve() {
    _resolveTimer?.cancel();
    _resolveTimer = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) {
        return;
      }
      final AppController app = context.read<AppController>();
      if (!app.loadCardImages) {
        return;
      }
      final List<OwnedComboEntry> visible = _visibleEntriesForPrefetch(app);
      if (visible.isEmpty) {
        return;
      }
      final List<AlchemyCard?> cards = <AlchemyCard?>[];
      for (final OwnedComboEntry e in visible) {
        cards.add(app.catalog[e.cardId]);
      }
      if (cards.every((AlchemyCard? c) => c == null)) {
        return;
      }
      await app.prefetchWikiImagesForCards(cards);
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  List<OwnedComboEntry> _visibleEntriesForPrefetch(AppController app) {
    final List<OwnedComboEntry> sorted = _sortedOwned(app);
    if (!app.uiCollapseDuplicates) {
      return sorted.take(40).toList();
    }
    final List<OwnedComboEntryGroup> groups = groupOwnedComboEntries(
      List<OwnedComboEntry>.from(sorted),
    );
    sortOwnedComboEntryGroups(
      groups,
      app.uiCardListSortMode,
      app.catalog,
      direction: app.uiCardListSortDirection,
    );
    return groups
        .take(40)
        .map((OwnedComboEntryGroup g) => g.representative)
        .toList();
  }

  List<OwnedComboEntryGroup> _sortedGroups(AppController app) {
    final List<OwnedComboEntry> sorted = _sortedOwned(app);
    final List<OwnedComboEntryGroup> groups = groupOwnedComboEntries(
      List<OwnedComboEntry>.from(sorted),
    );
    sortOwnedComboEntryGroups(
      groups,
      app.uiCardListSortMode,
      app.catalog,
      direction: app.uiCardListSortDirection,
    );
    return groups;
  }

  Future<void> _confirmRemoveCollectionEntry({
    required BuildContext context,
    required AppController app,
    required OwnedComboEntry entry,
    required AlchemyCard card,
    required int stackSize,
  }) async {
    final String body = stackSize > 1
        ? context.l10n.collectionDeleteOneFromGroup(card.displayName, stackSize)
        : context.l10n.collectionDeleteOne(card.displayName);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(context.l10n.collectionDeleteTitle),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await app.removeOwnedEntry(entry.entryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final List<OwnedComboEntry> rows = _sortedOwned(app);
    final List<OwnedComboEntryGroup>? groupsCollapsed = app.uiCollapseDuplicates
        ? _sortedGroups(app)
        : null;
    final Map<String, int> over = app.collectionGroupCountsOverLimit;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (over.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    context.l10n.collectionLimitWarning(
                      CollectionStore.maxCopiesPerDeckGroupName,
                      _formatOverflowNames(app, over),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openAddOneSheet(context, app),
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.collectionAddOne),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openBulkSheet(context, app),
                    icon: const Icon(Icons.library_add_outlined),
                    label: Text(context.l10n.collectionAddMany),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CardSortSelector(
                    mode: app.uiCardListSortMode,
                    direction: app.uiCardListSortDirection,
                    decoration: _compactDropdownDecoration(
                      context.l10n.labelSort,
                    ),
                    onModeChanged: (CardListSortMode mode) {
                      app.setUiCardListSortMode(mode);
                      _scheduleImageResolve();
                    },
                    onDirectionChanged: (CardListSortDirection direction) {
                      app.setUiCardListSortDirection(direction);
                      _scheduleImageResolve();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<ComboTier?>(
                    value: app.uiCatalogRarityTierFilter,
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
                    onChanged: (ComboTier? tier) {
                      app.setUiCatalogRarityTierFilter(tier);
                      _scheduleImageResolve();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DuplicateGroupingCheckbox(
                    value: app.uiCollapseDuplicates,
                    onChanged: (bool value) {
                      app.setUiCollapseDuplicates(value);
                      _scheduleImageResolve();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.l10n.collectionHint(
                CollectionStore.maxCopiesPerDeckGroupName,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.l10n.collectionStats(
                app.comboKindsOwned,
                app.totalComboCopies,
              ),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.collectionEmpty,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    itemCount: app.uiCollapseDuplicates
                        ? groupsCollapsed!.length
                        : rows.length,
                    itemBuilder: (BuildContext context, int i) {
                      if (app.uiCollapseDuplicates) {
                        final OwnedComboEntryGroup g = groupsCollapsed![i];
                        final OwnedComboEntry e = g.representative;
                        final AlchemyCard? c = app.catalog[e.cardId];
                        if (c == null) {
                          return const SizedBox.shrink();
                        }
                        final ({int attack, int defense}) scaled =
                            scaledCardInstanceStats(
                              card: c,
                              tier: e.tier,
                              level: e.level,
                            );
                        return GameCardInstanceRow(
                          card: c,
                          imageUrl: app.cachedWikiImageUrlForCard(c),
                          loadImage: app.loadCardImages,
                          frameTier: e.tier,
                          isFused: e.isFused,
                          title: c.displayName,
                          levelBadgeLabel: localizedLevelLabel(
                            context.l10n,
                            e.level,
                          ),
                          prefixBadgeLabel: g.count > 1 ? 'x${g.count}' : null,
                          rarityLabel: localizedRarityLabel(
                            context.l10n,
                            c.rarity,
                          ),
                          attack: scaled.attack,
                          defense: scaled.defense,
                          abilityText: c.fusionAbility,
                          trailing: <Widget>[
                            IconButton(
                              tooltip: context.l10n.collectionDeleteOneTooltip,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmRemoveCollectionEntry(
                                context: context,
                                app: app,
                                entry: e,
                                card: c,
                                stackSize: g.count,
                              ),
                            ),
                          ],
                        );
                      }
                      final OwnedComboEntry e = rows[i];
                      final AlchemyCard? c = app.catalog[e.cardId];
                      if (c == null) {
                        return const SizedBox.shrink();
                      }
                      final ({int attack, int defense}) scaled =
                          scaledCardInstanceStats(
                            card: c,
                            tier: e.tier,
                            level: e.level,
                          );
                      return GameCardInstanceRow(
                        card: c,
                        imageUrl: app.cachedWikiImageUrlForCard(c),
                        loadImage: app.loadCardImages,
                        frameTier: e.tier,
                        isFused: e.isFused,
                        title: c.displayName,
                        levelBadgeLabel: localizedLevelLabel(
                          context.l10n,
                          e.level,
                        ),
                        rarityLabel: localizedRarityLabel(
                          context.l10n,
                          c.rarity,
                        ),
                        attack: scaled.attack,
                        defense: scaled.defense,
                        abilityText: c.fusionAbility,
                        trailing: <Widget>[
                          IconButton(
                            tooltip: context.l10n.actionDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmRemoveCollectionEntry(
                              context: context,
                              app: app,
                              entry: e,
                              card: c,
                              stackSize: 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<OwnedComboEntry> _sortedOwned(AppController app) {
    final ComboTier? rarityFilter = app.uiCatalogRarityTierFilter;
    final List<OwnedComboEntry> list = app.ownedComboEntries.where((
      OwnedComboEntry entry,
    ) {
      if (rarityFilter == null) {
        return true;
      }
      final AlchemyCard? card = app.catalog[entry.cardId];
      if (card == null) {
        return false;
      }
      return comboTierFromCatalogRarity(card.rarity) == rarityFilter;
    }).toList();
    sortOwnedComboEntries(
      list,
      app.uiCardListSortMode,
      app.catalog,
      direction: app.uiCardListSortDirection,
    );
    return list;
  }

  String _formatOverflowNames(AppController app, Map<String, int> over) {
    final List<String> parts = <String>[];
    over.forEach((String groupKey, int n) {
      String label = groupKey;
      for (final OwnedComboEntry e in app.ownedComboEntries) {
        final AlchemyCard? c = app.catalog[e.cardId];
        if (c != null && c.deckGroupKey == groupKey) {
          label = c.displayName;
          break;
        }
      }
      parts.add('$label ($n)');
    });
    return parts.take(4).join(', ');
  }

  Future<void> _openAddOneSheet(BuildContext context, AppController app) async {
    await showAddOneComboCardSheet(
      context: context,
      app: app,
      onAdded: () {
        _scheduleImageResolve();
        setState(() {});
      },
    );
  }

  Future<void> _openBulkSheet(BuildContext context, AppController app) async {
    await showBulkAddComboCardSheet(
      context: context,
      app: app,
      onAdded: () {
        _scheduleImageResolve();
        setState(() {});
      },
    );
  }
}
