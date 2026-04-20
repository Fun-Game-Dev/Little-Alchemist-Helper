import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n_ext.dart';
import '../../models/combo_tier.dart';
import '../../models/deck_profile.dart';
import '../../models/deck_result.dart';
import '../../models/deck_settings.dart';
import '../../models/deck_focus_preset.dart';
import '../../models/owned_combo_entry.dart';
import '../../state/app_controller.dart';
import '../../util/card_list_groups.dart';
import '../../util/card_instance_stats.dart';
import '../../util/card_sort.dart';
import '../widgets/card_sort_selector.dart';
import '../widgets/duplicate_grouping_checkbox.dart';
import '../widgets/game_card_instance_row.dart';
import 'deck_edit_screen.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  InputDecoration _compactDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  String _localizedDeckFocusLabel(BuildContext context, DeckSettings settings) {
    switch (settings.focusPreset) {
      case DeckFocusPreset.attack:
        return context.l10n.deckFocusAttack;
      case DeckFocusPreset.defense:
        return context.l10n.deckFocusDefense;
      case DeckFocusPreset.sumStats:
        return context.l10n.deckFocusSumStats;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final DeckProfile? profile = app.selectedDeckProfile;
    final DeckSettings settings = profile?.settings ?? DeckSettings.defaults;
    final DeckOptimizationResult? r = app.lastDeckResult;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          context.l10n.deckActive,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: context.l10n.deckProfile,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: app.selectedDeckId,
                    items: <DropdownMenuItem<String>>[
                      for (final DeckProfile p in app.deckProfiles)
                        DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (String? id) {
                      if (id != null) {
                        app.selectDeck(id);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: context.l10n.deckNew,
              onPressed: () async {
                final bool added = await app.addDeckProfile();
                if (!context.mounted) {
                  return;
                }
                if (!added) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.saveFailedGeneric)),
                  );
                  return;
                }
                final DeckProfile? p = context
                    .read<AppController>()
                    .selectedDeckProfile;
                if (p != null) {
                  await Navigator.of(context, rootNavigator: true).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext ctx) =>
                          DeckEditScreen(profile: p, isNew: true),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: profile == null
              ? null
              : () {
                  Navigator.of(context, rootNavigator: true).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext ctx) =>
                          DeckEditScreen(profile: profile),
                    ),
                  );
                },
          icon: const Icon(Icons.tune),
          label: Text(context.l10n.deckEditSettings),
        ),
        if (app.deckProfiles.length > 1 && profile != null)
          TextButton.icon(
            onPressed: () async {
              final bool? ok = await showDialog<bool>(
                context: context,
                builder: (BuildContext ctx) => AlertDialog(
                  title: Text(context.l10n.deckDeleteConfirmTitle),
                  content: Text(
                    context.l10n.deckDeleteConfirmBody(profile.name),
                  ),
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
                final bool removed = await app.removeDeckProfile(profile.id);
                if (!removed && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.saveFailedGeneric)),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(context.l10n.deckDeleteThis),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            app.recomputeBestDeck();
            _prefetchDeckImages(context, app);
          },
          icon: const Icon(Icons.auto_awesome),
          label: Text(context.l10n.deckOptimizeButton),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.deckStatusSummary(
            _localizedDeckFocusLabel(context, settings),
            settings.deckSize,
            settings.seedEntryId ?? context.l10n.deckSeedNone,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (r == null) ...<Widget>[
          const SizedBox(height: 24),
          Text(
            app.totalComboCopies < 1
                ? context.l10n.deckNeedAtLeastOneCard
                : app.totalComboCopies < settings.deckSize
                ? context.l10n.deckNotEnoughCardsForSize(settings.deckSize)
                : context.l10n.deckTapBuildHint,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ] else ...<Widget>[
          const SizedBox(height: 16),
          if (r.usedHeuristic)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                context.l10n.deckHeuristicApprox,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          if (r.poolTruncated)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                context.l10n.deckPoolTruncated(r.consideredCount),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          Text(
            context.l10n.deckScoreSummary(
              r.totalScore.toStringAsFixed(1),
              r.soloScore.toStringAsFixed(1),
              r.fusionScore.toStringAsFixed(1),
              r.comboMergeScore.toStringAsFixed(0),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: CardSortSelector(
                  mode: app.uiCardListSortMode,
                  direction: app.uiCardListSortDirection,
                  decoration: _compactDropdownDecoration(
                    context.l10n.labelSort,
                  ),
                  onModeChanged: app.setUiCardListSortMode,
                  onDirectionChanged: app.setUiCardListSortDirection,
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
                  onChanged: app.setUiCatalogRarityTierFilter,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DuplicateGroupingCheckbox(
                  value: app.uiCollapseDuplicates,
                  onChanged: app.setUiCollapseDuplicates,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._deckRowsForResult(r, app),
        ],
      ],
    );
  }

  List<DeckPlannedSlot> _sortedDeckSlots(
    DeckOptimizationResult r,
    AppController app,
  ) {
    final ComboTier? rarityFilter = app.uiCatalogRarityTierFilter;
    final List<DeckPlannedSlot> copy = r.slots.where((DeckPlannedSlot slot) {
      if (rarityFilter == null) {
        return true;
      }
      return comboTierFromCatalogRarity(slot.catalogCard.rarity) ==
          rarityFilter;
    }).toList();
    sortDeckPlannedSlots(
      copy,
      app.uiCardListSortMode,
      direction: app.uiCardListSortDirection,
    );
    return copy;
  }

  List<Widget> _deckRowsForResult(DeckOptimizationResult r, AppController app) {
    final List<DeckPlannedSlot> flat = _sortedDeckSlots(r, app);
    if (!app.uiCollapseDuplicates) {
      return flat
          .map(
            (DeckPlannedSlot s) => _DeckSlotRow(
              slot: s,
              stackCount: 1,
              imageUrl: app.cachedWikiImageUrlForCard(s.catalogCard),
              loadImage: app.loadCardImages,
            ),
          )
          .toList();
    }
    final List<DeckPlannedSlotGroup> groups = groupDeckPlannedSlots(flat);
    sortDeckPlannedSlotGroups(
      groups,
      app.uiCardListSortMode,
      direction: app.uiCardListSortDirection,
    );
    return groups
        .map(
          (DeckPlannedSlotGroup g) => _DeckSlotRow(
            slot: g.representative,
            stackCount: g.count,
            imageUrl: app.cachedWikiImageUrlForCard(
              g.representative.catalogCard,
            ),
            loadImage: app.loadCardImages,
          ),
        )
        .toList();
  }

  Future<void> _prefetchDeckImages(
    BuildContext context,
    AppController app,
  ) async {
    final DeckOptimizationResult? r = app.lastDeckResult;
    if (r == null || !app.loadCardImages) {
      return;
    }
    await app.prefetchWikiImagesForCards(
      r.slots.map((DeckPlannedSlot s) => s.catalogCard),
    );
    if (!context.mounted) {
      return;
    }
    setState(() {});
  }
}

class _DeckSlotRow extends StatelessWidget {
  const _DeckSlotRow({
    required this.slot,
    required this.stackCount,
    required this.imageUrl,
    required this.loadImage,
  });

  final DeckPlannedSlot slot;
  final int stackCount;
  final String? imageUrl;
  final bool loadImage;

  @override
  Widget build(BuildContext context) {
    final OwnedComboEntry e = slot.entry;
    final ({int attack, int defense}) scaled = scaledCardInstanceStats(
      card: slot.catalogCard,
      tier: e.tier,
      level: e.level,
    );
    return GameCardInstanceRow(
      card: slot.catalogCard,
      imageUrl: imageUrl,
      loadImage: loadImage,
      frameTier: e.tier,
      isFused: e.isFused,
      title: slot.catalogCard.displayName,
      levelBadgeLabel: localizedLevelLabel(context.l10n, e.level),
      prefixBadgeLabel: stackCount > 1 ? 'x$stackCount' : null,
      rarityLabel: localizedRarityLabel(context.l10n, slot.catalogCard.rarity),
      attack: scaled.attack,
      defense: scaled.defense,
      abilityText: slot.catalogCard.fusionAbility,
    );
  }
}
