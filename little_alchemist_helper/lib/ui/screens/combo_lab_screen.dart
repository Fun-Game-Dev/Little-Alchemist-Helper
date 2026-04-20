import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_ext.dart';
import '../../data/synthetic_onyx_catalog_augment.dart';
import '../../models/alchemy_card.dart';
import '../../models/combo_battle_stats.dart';
import '../../models/combo_lab_material_pick.dart';
import '../../models/combo_tier.dart';
import '../../services/combo_graph_lookup.dart';
import '../../state/app_controller.dart';
import '../../util/card_instance_stats.dart';
import '../widgets/catalog_combo_card_sheet.dart';
import '../widgets/game_card_instance_row.dart';

/// Fusion-pair check and battle result level/stats calculation (wiki model).
class ComboLabScreen extends StatefulWidget {
  const ComboLabScreen({super.key});

  @override
  State<ComboLabScreen> createState() => _ComboLabScreenState();
}

class _ComboLabScreenState extends State<ComboLabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchVisible());
  }

  void _prefetchVisible() {
    if (!mounted) {
      return;
    }
    final AppController app = context.read<AppController>();
    final List<AlchemyCard?> cards = <AlchemyCard?>[];
    void addCard(String? cardId) {
      if (cardId == null) {
        return;
      }
      final AlchemyCard? c = app.catalog[cardId];
      if (c != null) {
        cards.add(c);
      }
    }

    addCard(app.comboLabPickA?.cardId);
    addCard(app.comboLabPickB?.cardId);
    final AlchemyCard? a = app.comboLabPickA != null
        ? app.catalog[app.comboLabPickA!.cardId]
        : null;
    final AlchemyCard? b = app.comboLabPickB != null
        ? app.catalog[app.comboLabPickB!.cardId]
        : null;
    if (a != null && b != null) {
      final String? rid = ComboGraphLookup.fusionResultCardId(a, b);
      if (rid != null) {
        final AlchemyCard? r = app.catalog[rid];
        if (r != null) {
          cards.add(r);
        }
      }
    }
    app.prefetchWikiImagesForCards(cards);
  }

  Future<void> _openPickSheet({
    required BuildContext context,
    required AppController app,
    required String title,
    required void Function(ComboLabMaterialPick value) onPicked,
    ComboLabMaterialPick? current,
  }) async {
    if (current != null) {
      final AlchemyCard? c = app.catalog[current.cardId];
      if (c != null) {
        await app.prefetchWikiImagesForCards(<AlchemyCard?>[c]);
      }
    }
    if (!context.mounted) {
      return;
    }
    final ComboLabMaterialPick? next = await showPickComboMaterialSheet(
      context: context,
      app: app,
      title: title,
      initialPick: current,
    );
    if (next != null && context.mounted) {
      onPicked(next);
      _prefetchVisible();
    }
  }

  ComboTier _maxInstanceTier(ComboLabMaterialPick? x, ComboLabMaterialPick? y) {
    if (x == null || y == null) {
      return ComboTier.bronze;
    }
    if (x.tier.sortIndex >= y.tier.sortIndex) {
      return x.tier;
    }
    return y.tier;
  }

  AlchemyCard? _card(AppController app, ComboLabMaterialPick? p) {
    if (p == null) {
      return null;
    }
    return app.catalog[p.cardId];
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final ComboLabMaterialPick? pickA = app.comboLabPickA;
    final ComboLabMaterialPick? pickB = app.comboLabPickB;
    final AlchemyCard? cardA = _card(app, pickA);
    final AlchemyCard? cardB = _card(app, pickB);
    final ({int attack, int defense})? scaledA =
        cardA != null && pickA != null
        ? scaledCardInstanceStats(
            card: cardA,
            tier: pickA.tier,
            level: pickA.level,
          )
        : null;
    final ({int attack, int defense})? scaledB =
        cardB != null && pickB != null
        ? scaledCardInstanceStats(
            card: cardB,
            tier: pickB.tier,
            level: pickB.level,
          )
        : null;

    final String? resultId = cardA != null && cardB != null
        ? ComboGraphLookup.fusionResultCardId(cardA, cardB)
        : null;
    final AlchemyCard? result = resultId != null ? app.catalog[resultId] : null;

    final ComboTier resultTier = result != null
        ? comboTierFromCatalogRarity(result.rarity)
        : ComboTier.bronze;

    final int onyxMaterialCount = pickA != null && pickB != null
        ? (pickA.tier == ComboTier.onyx ? 1 : 0) +
              (pickB.tier == ComboTier.onyx ? 1 : 0)
        : 0;
    final ComboResultOnyxShape onyxShape = onyxMaterialCount >= 2
        ? ComboResultOnyxShape.full
        : onyxMaterialCount == 1
        ? ComboResultOnyxShape.half
        : ComboResultOnyxShape.none;

    final int battleLevel = result != null && pickA != null && pickB != null
        ? ComboBattleStats.resultLevel(
            materialLevelA: pickA.battleMaterialLevel,
            materialLevelB: pickB.battleMaterialLevel,
            resultTier: resultTier,
            onyxShape: onyxShape,
          )
        : 1;

    final ({int attack, int defense}) scaled =
        result != null && pickA != null && pickB != null
        ? _scaledFusionPreview(
            app: app,
            cardA: cardA!,
            cardB: cardB!,
            result: result,
            battleLevel: battleLevel,
            onyxMaterialCount: onyxMaterialCount,
            onyxShape: onyxShape,
            highestMaterial: _maxInstanceTier(pickA, pickB),
            resultTier: resultTier,
          )
        : (attack: 0, defense: 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          context.l10n.comboLabIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.comboCardA,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (cardA != null && pickA != null)
          GameCardInstanceRow(
            card: cardA,
            imageUrl: app.cachedWikiImageUrlForCard(cardA),
            loadImage: app.loadCardImages,
            frameTier: pickA.tier,
            isFused: pickA.isFused,
            title: cardA.displayName,
            levelBadgeLabel: localizedLevelLabel(context.l10n, pickA.level),
            rarityLabel: localizedRarityLabel(context.l10n, cardA.rarity),
            attack: scaledA?.attack,
            defense: scaledA?.defense,
            abilityText: cardA.fusionAbility,
            trailing: <Widget>[
              IconButton(
                tooltip: context.l10n.comboChange,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openPickSheet(
                  context: context,
                  app: app,
                  title: context.l10n.comboCardA,
                  current: pickA,
                  onPicked: (ComboLabMaterialPick v) => app.setComboLabPickA(v),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: () => _openPickSheet(
              context: context,
              app: app,
              title: context.l10n.comboCardA,
              current: null,
              onPicked: (ComboLabMaterialPick v) => app.setComboLabPickA(v),
            ),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.comboPickA),
          ),
        const SizedBox(height: 16),
        Text(
          context.l10n.comboCardB,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (cardB != null && pickB != null)
          GameCardInstanceRow(
            card: cardB,
            imageUrl: app.cachedWikiImageUrlForCard(cardB),
            loadImage: app.loadCardImages,
            frameTier: pickB.tier,
            isFused: pickB.isFused,
            title: cardB.displayName,
            levelBadgeLabel: localizedLevelLabel(context.l10n, pickB.level),
            rarityLabel: localizedRarityLabel(context.l10n, cardB.rarity),
            attack: scaledB?.attack,
            defense: scaledB?.defense,
            abilityText: cardB.fusionAbility,
            trailing: <Widget>[
              IconButton(
                tooltip: context.l10n.comboChange,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openPickSheet(
                  context: context,
                  app: app,
                  title: context.l10n.comboCardB,
                  current: pickB,
                  onPicked: (ComboLabMaterialPick v) => app.setComboLabPickB(v),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: () => _openPickSheet(
              context: context,
              app: app,
              title: context.l10n.comboCardB,
              current: null,
              onPicked: (ComboLabMaterialPick v) => app.setComboLabPickB(v),
            ),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.comboPickB),
          ),
        const SizedBox(height: 20),
        Text(
          context.l10n.comboResult,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (cardA == null || cardB == null)
          Text(
            context.l10n.comboPickBoth,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else if (result == null)
          Text(
            context.l10n.comboNoRecipe(cardA.displayName, cardB.displayName),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          GameCardInstanceRow(
            margin: EdgeInsets.zero,
            card: result,
            imageUrl: app.cachedWikiImageUrlForCard(result),
            loadImage: app.loadCardImages,
            frameTier: resultTier,
            isFused: result.isFusedVariant,
            title: result.displayName,
            levelBadgeLabel: context.l10n.comboBattleLevel(battleLevel),
            rarityLabel: localizedRarityLabel(context.l10n, result.rarity),
            attack: scaled.attack,
            defense: scaled.defense,
            abilityText: result.fusionAbility,
            detailWidgets: <Widget>[
              Text(
                context.l10n.comboResultId(result.cardId),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _fusionPreviewStatsCaption(
                  l10n: context.l10n,
                  app: app,
                  cardA: cardA,
                  cardB: cardB,
                  onyxMaterialCount: onyxMaterialCount,
                  scaled: scaled,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (onyxShape != ComboResultOnyxShape.none)
                Text(
                  onyxMaterialCount >= 2
                      ? context.l10n.comboMaterialsDoubleOnyx
                      : context.l10n.comboMaterialsMixed,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
      ],
    );
  }
}

({int attack, int defense}) _scaledFusionPreview({
  required AppController app,
  required AlchemyCard cardA,
  required AlchemyCard cardB,
  required AlchemyCard result,
  required int battleLevel,
  required int onyxMaterialCount,
  required ComboResultOnyxShape onyxShape,
  required ComboTier highestMaterial,
  required ComboTier resultTier,
}) {
  final List<int>? sheetPair = app.fusionOnyxSheet?.resultAttackDefense(
    SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(cardA.cardId),
    SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(cardB.cardId),
    onyxMaterialCount,
  );
  if (sheetPair != null && sheetPair.length >= 2) {
    // Sheet provides base A/D for this onyx-material scenario; apply level growth
    // using the same per-level rules as in regular calculation path.
    final ({int attack, int defense}) d = ComboBattleStats.perLevelBonus(
      highestMaterial,
    );
    final int effectiveLevel =
        battleLevel.clamp(1, ComboBattleStats.maxStatScalingLevel);
    final int steps = effectiveLevel - 1;
    return (
      attack: sheetPair[0] + d.attack * steps,
      defense: sheetPair[1] + d.defense * steps,
    );
  }
  ({int attack, int defense}) scaled = ComboBattleStats.scaledResultStats(
    resultBaseAttack: result.attack,
    resultBaseDefense: result.defense,
    resultLevel: battleLevel,
    highestMaterialTier: highestMaterial,
  );
  if (battleLevel == 6 && onyxShape != ComboResultOnyxShape.none) {
    final ({int attack, int defense})? b = ComboBattleStats.onyxTable3Bonus(
      shape: onyxShape,
      originalResultTier: resultTier,
    );
    if (b != null) {
      scaled = (
        attack: scaled.attack + b.attack,
        defense: scaled.defense + b.defense,
      );
    }
  }
  return scaled;
}

String _fusionPreviewStatsCaption({
  required AppLocalizations l10n,
  required AppController app,
  required AlchemyCard cardA,
  required AlchemyCard cardB,
  required int onyxMaterialCount,
  required ({int attack, int defense}) scaled,
}) {
  final bool fromSheet =
      app.fusionOnyxSheet?.resultAttackDefense(
        SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(
          cardA.cardId,
        ),
        SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(
          cardB.cardId,
        ),
        onyxMaterialCount,
      ) !=
      null;
  if (fromSheet) {
    return l10n.comboPreviewStatsFromSheet(scaled.attack, scaled.defense);
  }
  return l10n.comboPreviewStatsEstimated(scaled.attack, scaled.defense);
}
