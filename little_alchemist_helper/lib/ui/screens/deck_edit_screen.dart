import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n_ext.dart';
import '../../models/alchemy_card.dart';
import '../../models/combo_tier.dart';
import '../../models/deck_focus_preset.dart';
import '../../models/deck_profile.dart';
import '../../models/deck_settings.dart';
import '../../models/owned_combo_entry.dart';
import '../../state/app_controller.dart';
import '../../util/card_instance_stats.dart';
import '../../util/card_sort.dart';
import '../widgets/card_sort_selector.dart';
import '../widgets/game_card_instance_row.dart';

/// Saved deck and auto-build settings: flat fields without unnecessary nesting.
class DeckEditScreen extends StatefulWidget {
  const DeckEditScreen({super.key, required this.profile, this.isNew = false});

  final DeckProfile profile;
  final bool isNew;

  @override
  State<DeckEditScreen> createState() => _DeckEditScreenState();
}

class _DeckEditScreenState extends State<DeckEditScreen> {
  late final TextEditingController _name;
  late DeckSettings _settings;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _settings = widget.profile.settings;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context, AppController app) async {
    final String n = _name.text.trim();
    if (n.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.deckNameRequired)));
      }
      return;
    }
    DeckProfile? base;
    for (final DeckProfile p in app.deckProfiles) {
      if (p.id == widget.profile.id) {
        base = p;
        break;
      }
    }
    base ??= widget.profile;
    final DeckProfile next = base.copyWith(
      name: n,
      settings: _settings.copyWith(
        deckSize: _settings.deckSize.clamp(
          DeckSettings.minDeckSize,
          DeckSettings.maxDeckSize,
        ),
        maxNonFusionCards: _settings.maxNonFusionCards.clamp(
          DeckSettings.minMaxNonFusionCards,
          DeckSettings.maxMaxNonFusionCards,
        ),
      ),
    );
    final bool saved = await app.updateDeckProfile(next);
    if (!context.mounted) {
      return;
    }
    if (saved) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.saveFailedGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final int deckClamped = _settings.deckSize.clamp(
      DeckSettings.minDeckSize,
      DeckSettings.maxDeckSize,
    );
    OwnedComboEntry? seedEntry;
    for (final OwnedComboEntry e in app.ownedComboEntries) {
      if (e.entryId == _settings.seedEntryId) {
        seedEntry = e;
        break;
      }
    }
    final AlchemyCard? seedCard = seedEntry == null
        ? null
        : app.catalog[seedEntry.cardId];
    final ({int attack, int defense})? seedScaled =
        seedCard != null && seedEntry != null
        ? scaledCardInstanceStats(
            card: seedCard,
            tier: seedEntry.tier,
            level: seedEntry.level,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNew ? context.l10n.deckNew : context.l10n.deckEditSettings,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => _save(context, app),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              context.l10n.deckName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.deckSeedCard,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (seedCard != null && seedEntry != null)
              GameCardInstanceRow(
                margin: EdgeInsets.zero,
                card: seedCard,
                imageUrl: app.cachedWikiImageUrlForCard(seedCard),
                loadImage: app.loadCardImages,
                frameTier: seedEntry.tier,
                isFused: seedEntry.isFused,
                title: seedCard.displayName,
                levelBadgeLabel: localizedLevelLabel(
                  context.l10n,
                  seedEntry.level,
                ),
                rarityLabel: localizedRarityLabel(
                  context.l10n,
                  seedCard.rarity,
                ),
                attack: seedScaled?.attack,
                defense: seedScaled?.defense,
                abilityText: seedCard.fusionAbility,
                trailing: <Widget>[
                  IconButton(
                    tooltip: context.l10n.comboChange,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () async {
                      final OwnedComboEntry? selected = await _pickSeedEntry(
                        context,
                        app,
                      );
                      if (selected == null) {
                        return;
                      }
                      setState(() {
                        _settings = _settings.copyWith(
                          seedEntryId: selected.entryId,
                        );
                      });
                    },
                  ),
                ],
              )
            else ...<Widget>[
              Text(
                context.l10n.deckSeedHint,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final OwnedComboEntry? selected = await _pickSeedEntry(
                    context,
                    app,
                  );
                  if (selected == null) {
                    return;
                  }
                  setState(() {
                    _settings = _settings.copyWith(
                      seedEntryId: selected.entryId,
                    );
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(context.l10n.deckPickSeed),
              ),
            ],
            const Divider(height: 32),
            Text(
              context.l10n.deckFillType,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.deckFillHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DeckFocusPreset.values.map((DeckFocusPreset p) {
                return ChoiceChip(
                  label: Text(_focusPresetLabel(context, p)),
                  selected: _settings.focusPreset == p,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(
                        () => _settings = _settings.copyWith(focusPreset: p),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.deckComboVsStatsBalance(
                _settings.comboVsStatsBalance.toStringAsFixed(2),
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              context.l10n.deckComboVsStatsBalanceHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Slider(
              value: _settings.comboVsStatsBalance.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              divisions: 20,
              label: _settings.comboVsStatsBalance.toStringAsFixed(2),
              onChanged: (double v) {
                setState(
                  () => _settings = _settings.copyWith(
                    comboVsStatsBalance: (v * 20).round() / 20,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.deckComboVsHandBalance(
                _settings.comboVsHandBalance.toStringAsFixed(2),
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              context.l10n.deckComboVsHandBalanceHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Slider(
              value: _settings.comboVsHandBalance.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              divisions: 20,
              label: _settings.comboVsHandBalance.toStringAsFixed(2),
              onChanged: (double v) {
                setState(
                  () => _settings = _settings.copyWith(
                    comboVsHandBalance: DeckSettings.snapBalance05(v),
                  ),
                );
              },
            ),
            const Divider(height: 32),
            Text(
              context.l10n.deckSize(deckClamped),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: deckClamped.toDouble(),
              min: DeckSettings.minDeckSize.toDouble(),
              max: DeckSettings.maxDeckSize.toDouble(),
              divisions: DeckSettings.maxDeckSize - DeckSettings.minDeckSize,
              label: '$deckClamped',
              onChanged: (double v) {
                setState(
                  () => _settings = _settings.copyWith(deckSize: v.round()),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.deckMaxNonFusion(
                _settings.maxNonFusionCards.clamp(
                  DeckSettings.minMaxNonFusionCards,
                  DeckSettings.maxMaxNonFusionCards,
                ),
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _settings.maxNonFusionCards
                  .clamp(
                    DeckSettings.minMaxNonFusionCards,
                    DeckSettings.maxMaxNonFusionCards,
                  )
                  .toDouble(),
              min: DeckSettings.minMaxNonFusionCards.toDouble(),
              max: DeckSettings.maxMaxNonFusionCards.toDouble(),
              divisions:
                  DeckSettings.maxMaxNonFusionCards -
                  DeckSettings.minMaxNonFusionCards,
              label:
                  '${_settings.maxNonFusionCards.clamp(DeckSettings.minMaxNonFusionCards, DeckSettings.maxMaxNonFusionCards)}',
              onChanged: (double v) {
                setState(
                  () => _settings = _settings.copyWith(
                    maxNonFusionCards: v.round(),
                  ),
                );
              },
            ),
            const Divider(height: 24),
            Text(
              context.l10n.deckRarityRules,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.deckRarityRulesHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ...ComboTier.values.map((ComboTier tier) {
              final DeckRarityRule rule = _settings.rarityRules.ruleFor(tier);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        localizedTierLabel(context.l10n, tier),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.deckMinLevel(
                          localizedLevelLabel(context.l10n, rule.minLevel),
                        ),
                      ),
                      Slider(
                        value: rule.minLevel.toDouble(),
                        min: OwnedComboEntry.minLevel.toDouble(),
                        max: OwnedComboEntry.maxLevel.toDouble(),
                        divisions:
                            OwnedComboEntry.maxLevel - OwnedComboEntry.minLevel,
                        label: localizedLevelLabel(context.l10n, rule.minLevel),
                        onChanged: (double v) {
                          final DeckRarityRule nextRule = rule.copyWith(
                            minLevel: v.round(),
                          );
                          setState(
                            () => _settings = _settings.copyWith(
                              rarityRules: _settings.rarityRules.copyWithTier(
                                tier,
                                nextRule,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _focusPresetLabel(BuildContext context, DeckFocusPreset preset) {
    switch (preset) {
      case DeckFocusPreset.attack:
        return context.l10n.deckFocusAttack;
      case DeckFocusPreset.defense:
        return context.l10n.deckFocusDefense;
      case DeckFocusPreset.sumStats:
        return context.l10n.deckFocusSumStats;
    }
  }

  Future<OwnedComboEntry?> _pickSeedEntry(
    BuildContext context,
    AppController app,
  ) async {
    final List<OwnedComboEntry> entries = app.ownedComboEntries
        .where((OwnedComboEntry e) => app.cardCanFuse(e.cardId))
        .toList();
    if (entries.isEmpty) {
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.deckNoSeedCandidates)),
      );
      return null;
    }
    return showModalBottomSheet<OwnedComboEntry>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return _DeckSeedEntryPickSheet(
          app: app,
          entries: entries,
          popContext: sheetContext,
        );
      },
    );
  }
}

class _DeckSeedEntryPickSheet extends StatefulWidget {
  const _DeckSeedEntryPickSheet({
    required this.app,
    required this.entries,
    required this.popContext,
  });

  final AppController app;
  final List<OwnedComboEntry> entries;
  final BuildContext popContext;

  @override
  State<_DeckSeedEntryPickSheet> createState() =>
      _DeckSeedEntryPickSheetState();
}

class _DeckSeedEntryPickSheetState extends State<_DeckSeedEntryPickSheet> {
  final TextEditingController _q = TextEditingController();
  String _query = '';
  late CardListSortMode _sortMode;
  late CardListSortDirection _sortDirection;
  ComboTier? _rarityFilter;

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
    _sortMode = widget.app.uiCardListSortMode;
    _sortDirection = widget.app.uiCardListSortDirection;
    _rarityFilter = widget.app.uiCatalogRarityTierFilter;
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<OwnedComboEntry> _rows() {
    final List<OwnedComboEntry> rows = List<OwnedComboEntry>.from(
      widget.entries,
    );
    sortOwnedComboEntries(
      rows,
      _sortMode,
      widget.app.catalog,
      direction: _sortDirection,
    );
    return rows.where((OwnedComboEntry e) {
      final AlchemyCard? c = widget.app.catalog[e.cardId];
      if (c == null) {
        return false;
      }
      if (_rarityFilter != null &&
          comboTierFromCatalogRarity(c.rarity) != _rarityFilter) {
        return false;
      }
      if (_query.isEmpty) {
        return true;
      }
      final String name = c.displayName.toLowerCase();
      return name.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<OwnedComboEntry> rows = _rows();
    final double inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController sc) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.deckPickSeedTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _q,
                  decoration: InputDecoration(
                    hintText: context.l10n.catalogSearchHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (String v) {
                    setState(() {
                      _query = v.trim().toLowerCase();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CardSortSelector(
                        mode: _sortMode,
                        direction: _sortDirection,
                        decoration: _compactDropdownDecoration(
                          context.l10n.labelSort,
                        ),
                        onModeChanged: (CardListSortMode mode) {
                          setState(() => _sortMode = mode);
                          widget.app.setUiCardListSortMode(mode);
                        },
                        onDirectionChanged: (CardListSortDirection direction) {
                          setState(() => _sortDirection = direction);
                          widget.app.setUiCardListSortDirection(direction);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<ComboTier?>(
                        value: _rarityFilter,
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
                          setState(() => _rarityFilter = tier);
                          widget.app.setUiCatalogRarityTierFilter(tier);
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
                        itemBuilder: (BuildContext context, int index) {
                          final OwnedComboEntry entry = rows[index];
                          final AlchemyCard? card =
                              widget.app.catalog[entry.cardId];
                          if (card == null) {
                            return const SizedBox.shrink();
                          }
                          final ({int attack, int defense}) scaled =
                              scaledCardInstanceStats(
                                card: card,
                                tier: entry.tier,
                                level: entry.level,
                              );
                          return GameCardInstanceRow(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            card: card,
                            imageUrl: widget.app.cachedWikiImageUrlForCard(
                              card,
                            ),
                            loadImage: widget.app.loadCardImages,
                            frameTier: entry.tier,
                            isFused: entry.isFused,
                            title: card.displayName,
                            levelBadgeLabel: localizedLevelLabel(
                              context.l10n,
                              entry.level,
                            ),
                            rarityLabel: localizedRarityLabel(
                              context.l10n,
                              card.rarity,
                            ),
                            attack: scaled.attack,
                            defense: scaled.defense,
                            abilityText: card.fusionAbility,
                            onTap: () =>
                                Navigator.pop(widget.popContext, entry),
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
