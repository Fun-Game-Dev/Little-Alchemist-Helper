import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/alchemy_card.dart';
import '../../models/combo_tier.dart';
import '../../services/card_image_cache.dart';

/// Card face (image or placeholder). Tier and fused effect are rendered in [GameCardInstanceRow].
class CardFace extends StatefulWidget {
  const CardFace({
    super.key,
    required this.card,
    required this.imageUrl,
    required this.loadImage,
    this.width = 72,
    this.height = 96,
  });

  final AlchemyCard card;
  final String? imageUrl;
  final bool loadImage;
  final double width;
  final double height;

  static const double _imageRadius = 8;

  @override
  State<CardFace> createState() => _CardFaceState();
}

class _CardFaceState extends State<CardFace> {
  late Future<CardImageSource> _sourceFuture;

  @override
  void initState() {
    super.initState();
    _sourceFuture = _resolveSource();
  }

  @override
  void didUpdateWidget(covariant CardFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.displayName != widget.card.displayName ||
        oldWidget.card.rarity != widget.card.rarity ||
        oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.loadImage != widget.loadImage) {
      _sourceFuture = _resolveSource();
    }
  }

  Future<CardImageSource> _resolveSource() {
    final bool isOnyxWikiArt =
        comboTierFromCatalogRarity(widget.card.rarity) == ComboTier.onyx;
    return resolveCardImageSource(
      displayName: widget.card.displayName,
      isOnyxTier: isOnyxWikiArt,
      networkUrl: widget.imageUrl,
      allowNetworkFetch: widget.loadImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget inner = FutureBuilder<CardImageSource>(
      future: _sourceFuture,
      builder: (BuildContext context, AsyncSnapshot<CardImageSource> snapshot) {
        final CardImageSource source = snapshot.data ?? const CardImageSource.none();
        if (source.hasAsset) {
          return Image.asset(
            source.assetPath!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) =>
                    _placeholder(theme),
          );
        }
        if (source.hasNetwork) {
          return CachedNetworkImage(
            imageUrl: source.networkUrl!,
            cacheManager: cardImageCacheManager,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            memCacheWidth: (widget.width * MediaQuery.devicePixelRatioOf(context))
                .round()
                .clamp(1, 512),
            placeholder: (BuildContext context, String url) => SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (BuildContext context, String url, Object error) =>
                _placeholder(theme),
          );
        }
        return _placeholder(theme);
      },
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(CardFace._imageRadius),
      child: SizedBox(width: widget.width, height: widget.height, child: inner),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            widget.card.displayName,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}
