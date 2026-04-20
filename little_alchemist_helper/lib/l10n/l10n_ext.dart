import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import '../models/catalog_owned_presence_filter.dart';
import '../models/combo_tier.dart';
import '../util/card_sort.dart';
import '../models/owned_combo_entry.dart';

extension AppL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

String localizedTierLabel(AppLocalizations l10n, ComboTier tier) {
  switch (tier) {
    case ComboTier.bronze:
      return l10n.tierBronze;
    case ComboTier.silver:
      return l10n.tierSilver;
    case ComboTier.gold:
      return l10n.tierGold;
    case ComboTier.diamond:
      return l10n.tierDiamond;
    case ComboTier.onyx:
      return l10n.tierOnyx;
  }
}

String localizedSortModeLabel(AppLocalizations l10n, CardListSortMode mode) {
  switch (mode) {
    case CardListSortMode.byName:
      return l10n.sortByName;
    case CardListSortMode.byRarity:
      return l10n.sortByRarity;
    case CardListSortMode.byPower:
      return l10n.sortByPower;
  }
}

String localizedPresenceLabel(
  AppLocalizations l10n,
  CatalogOwnedPresenceFilter filter,
) {
  switch (filter) {
    case CatalogOwnedPresenceFilter.all:
      return l10n.labelAll;
    case CatalogOwnedPresenceFilter.inCollection:
      return l10n.presenceInCollection;
    case CatalogOwnedPresenceFilter.notInCollection:
      return l10n.presenceNotInCollection;
  }
}

String localizedRarityLabel(AppLocalizations l10n, String rarity) {
  switch (rarity.trim().toLowerCase()) {
    case 'common':
      return l10n.tierBronze;
    case 'uncommon':
      return l10n.tierSilver;
    case 'rare':
      return l10n.tierGold;
    case 'diamond':
      return l10n.tierDiamond;
    case 'onyx':
      return l10n.tierOnyx;
    default:
      return l10n.rarityUnknown;
  }
}

String localizedLevelLabel(AppLocalizations l10n, int level) {
  final int clamped = level.clamp(
    OwnedComboEntry.minLevel,
    OwnedComboEntry.maxLevel,
  );
  if (clamped >= OwnedComboEntry.fusedLevel) {
    return l10n.levelFused;
  }
  return l10n.levelShort(clamped);
}
