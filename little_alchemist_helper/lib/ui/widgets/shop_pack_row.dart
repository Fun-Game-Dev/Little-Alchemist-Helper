import 'package:flutter/material.dart';

import '../../services/card_image_cache.dart';
import '../../util/card_display_emojis.dart';

final Color _kPackTextPlateColor =
    const Color.fromARGB(255, 222, 218, 218).withValues(alpha: 0.88);

/// Pack row matching [GameCardInstanceRow] layout (image + text plate), without tier/fusion effects.
class ShopPackRow extends StatefulWidget {
  const ShopPackRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.scheduleImageFile,
    required this.selectorFile,
    this.goldLabel,
    this.onyxLabel,
    this.inShopNow = false,
    this.onTap,
    this.faceWidth = 72,
    this.faceHeight = 96,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  final String title;
  final String subtitle;
  /// Bundled filename from rotation schedule, e.g. `2026_06_29_accursed.png`.
  final String? scheduleImageFile;
  final String selectorFile;
  /// Pre-formatted line (e.g. localized "Gold: Monkey"), or `null` to hide.
  final String? goldLabel;
  final String? onyxLabel;
  final bool inShopNow;
  final VoidCallback? onTap;
  final double faceWidth;
  final double faceHeight;
  final EdgeInsetsGeometry margin;

  static const double _panelRadius = 12;
  static const double _textPlateRadius = 10;

  @override
  State<ShopPackRow> createState() => _ShopPackRowState();
}

class _ShopPackRowState extends State<ShopPackRow> {
  late Future<CardImageSource> _sourceFuture;

  @override
  void initState() {
    super.initState();
    _sourceFuture = _resolve();
  }

  @override
  void didUpdateWidget(covariant ShopPackRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scheduleImageFile != widget.scheduleImageFile ||
        oldWidget.selectorFile != widget.selectorFile) {
      _sourceFuture = _resolve();
    }
  }

  Future<CardImageSource> _resolve() {
    return resolveShopPackImageSource(
      scheduleImageFile: widget.scheduleImageFile,
      selectorFile: widget.selectorFile,
      wikiImageUrl: '',
      allowNetworkFetch: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget face = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: widget.faceWidth,
        height: widget.faceHeight,
        child: FutureBuilder<CardImageSource>(
          future: _sourceFuture,
          builder: (BuildContext context, AsyncSnapshot<CardImageSource> snapshot) {
            final CardImageSource source =
                snapshot.data ?? const CardImageSource.none();
            if (source.hasAsset) {
              return Image.asset(
                source.assetPath!,
                width: widget.faceWidth,
                height: widget.faceHeight,
                fit: BoxFit.cover,
                errorBuilder:
                    (BuildContext context, Object error, StackTrace? stackTrace) =>
                        _placeholder(theme),
              );
            }
            return _placeholder(theme);
          },
        ),
      ),
    );

    final Widget textPlate = DecoratedBox(
      decoration: BoxDecoration(
        color: _kPackTextPlateColor,
        borderRadius: BorderRadius.circular(ShopPackRow._textPlateRadius),
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
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if ((widget.onyxLabel != null && widget.onyxLabel!.isNotEmpty) ||
                (widget.goldLabel != null && widget.goldLabel!.isNotEmpty)) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (widget.onyxLabel != null &&
                      widget.onyxLabel!.isNotEmpty)
                    _ShopPackComboBadge(
                      emoji: rarityTierEmoji('onyx'),
                      text: widget.onyxLabel!,
                      foreground: theme.colorScheme.secondary,
                    ),
                  if (widget.goldLabel != null &&
                      widget.goldLabel!.isNotEmpty)
                    _ShopPackComboBadge(
                      emoji: rarityTierEmoji('rare'),
                      text: widget.goldLabel!,
                      foreground: theme.colorScheme.tertiary,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    final Widget row = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          face,
          const SizedBox(width: 12),
          Expanded(child: textPlate),
        ],
      ),
    );

    final Widget inner = widget.onTap == null
        ? row
        : Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(ShopPackRow._panelRadius),
              child: row,
            ),
          );

    final BoxDecoration deco = BoxDecoration(
      color: widget.inShopNow
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(ShopPackRow._panelRadius),
      border: Border.all(
        color: widget.inShopNow
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant,
        width: widget.inShopNow ? 2 : 1,
      ),
    );

    return Container(
      margin: widget.margin,
      child: DecoratedBox(decoration: deco, child: inner),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 36,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}

/// Compact pill for Gold / Onyx combo lines (matches [GameCardInstanceRow] meta badges).
class _ShopPackComboBadge extends StatelessWidget {
  const _ShopPackComboBadge({
    required this.emoji,
    required this.text,
    required this.foreground,
  });

  final String emoji;
  final String text;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        '$emoji $text',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
