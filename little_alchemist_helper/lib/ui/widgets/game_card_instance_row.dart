import 'package:flutter/material.dart';

import '../../models/alchemy_card.dart';
import '../../models/combo_tier.dart';
import '../../util/card_display_emojis.dart';
import 'card_face.dart';
import 'rarity_card_chrome.dart';

final Color _kCardTextPlateColor = const Color.fromARGB(255, 222, 218, 218).withValues(alpha: 0.88);

/// Shared "card face + text" row for deck, collection, and related screens.
class GameCardInstanceRow extends StatelessWidget {
  const GameCardInstanceRow({
    super.key,
    required this.card,
    required this.imageUrl,
    required this.loadImage,
    required this.frameTier,
    required this.isFused,
    required this.title,
    this.detailWidgets = const <Widget>[],
    this.trailing,
    this.onTap,
    this.faceWidth = 72,
    this.faceHeight = 96,
    this.margin = const EdgeInsets.only(bottom: 10),
    this.selected = false,
    this.levelBadgeLabel,
    this.prefixBadgeLabel,
    this.rarityLabel,
    this.attack,
    this.defense,
    this.abilityText,
  });

  final AlchemyCard card;
  final String? imageUrl;
  final bool loadImage;
  final ComboTier frameTier;
  final bool isFused;
  final String title;
  final List<Widget> detailWidgets;
  final List<Widget>? trailing;
  final VoidCallback? onTap;
  final double faceWidth;
  final double faceHeight;
  final EdgeInsetsGeometry margin;
  final bool selected;

  /// Shared prominent level badge (instance, battle, etc.); screen provides the label text.
  final String? levelBadgeLabel;
  final String? prefixBadgeLabel;
  final String? rarityLabel;
  final int? attack;
  final int? defense;
  final String? abilityText;

  static const double _panelRadius = 12;
  static const double _textPlateRadius = 10;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool fusionFx = isFused || card.isFusedVariant;

    final Widget textPlate = DecoratedBox(
      decoration: BoxDecoration(
        color: _kCardTextPlateColor,
        borderRadius: BorderRadius.circular(_textPlateRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (prefixBadgeLabel != null) ...<Widget>[
                  _InstanceLevelBadge(label: prefixBadgeLabel!),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (levelBadgeLabel != null) ...<Widget>[
                  const SizedBox(width: 8),
                  _InstanceLevelBadge(label: levelBadgeLabel!),
                ],
              ],
            ),
            if (rarityLabel != null ||
                attack != null ||
                defense != null ||
                (abilityText != null && abilityText!.trim().isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    if (rarityLabel != null)
                      _MetaBadge(
                        label:
                            '${rarityTierEmoji(card.rarity)} $rarityLabel',
                      ),
                    if (attack != null) _MetaBadge(label: '⚔️ $attack'),
                    if (defense != null) _MetaBadge(label: '🛡️ $defense'),
                    if (abilityText != null && abilityText!.trim().isNotEmpty)
                      _MetaBadge(
                        label:
                            '${fusionAbilityEmoji(abilityText!)} ${abilityText!.trim()}',
                        maxWidth: 260,
                      ),
                  ],
                ),
              ),
            ...detailWidgets,
          ],
        ),
      ),
    );

    final List<Widget>? wrappedTrailing = trailing == null || trailing!.isEmpty
        ? null
        : trailing!
              .map(
                (Widget w) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _CircularWhiteIconSlot(child: w),
                ),
              )
              .toList(growable: false);

    final Widget row = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CardFace(
            card: card,
            imageUrl: imageUrl,
            loadImage: loadImage,
            width: faceWidth,
            height: faceHeight,
          ),
          const SizedBox(width: 12),
          Expanded(child: textPlate),
          if (wrappedTrailing != null)
            Row(mainAxisSize: MainAxisSize.min, children: wrappedTrailing),
        ],
      ),
    );

    final Widget panelChild = onTap == null
        ? row
        : Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(_panelRadius),
              child: row,
            ),
          );

    final Widget tierPanel = RarityTierPanel(
      tier: frameTier,
      fusionAnimated: fusionFx,
      borderRadius: BorderRadius.circular(_panelRadius),
      selectionOverlay: selected
          ? ColoredBox(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            )
          : null,
      child: panelChild,
    );

    return Container(
      margin: margin,
      decoration: selected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(_panelRadius + 2),
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            )
          : null,
      padding: selected ? const EdgeInsets.all(2) : EdgeInsets.zero,
      child: tierPanel,
    );
  }
}

/// Round white background for [IconButton] and similar trailing-row buttons.
/// Shared style for level caption on the card panel.
class _InstanceLevelBadge extends StatelessWidget {
  const _InstanceLevelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fg = theme.colorScheme.onSecondaryContainer;
    final Color bg = theme.colorScheme.secondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _CircularWhiteIconSlot extends StatelessWidget {
  const _CircularWhiteIconSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kCardTextPlateColor,
      elevation: 0,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black26,
      child: child,
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, this.maxWidth});

  final String label;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget content = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w700,
      ),
    );
    return Container(
      constraints: maxWidth == null
          ? null
          : BoxConstraints(maxWidth: maxWidth!),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: content,
    );
  }
}
