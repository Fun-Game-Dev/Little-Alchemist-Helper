import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'wiki_image_url_service.dart';

/// Disk cache for card previews with long freshness to avoid re-downloading files.
final CacheManager cardImageCacheManager = CacheManager(
  Config(
    'little_alchemist_card_images_v1',
    stalePeriod: const Duration(days: 365),
    maxNrOfCacheObjects: 8000,
  ),
);

class CardImageSource {
  const CardImageSource._({
    required this.assetPath,
    required this.networkUrl,
  });

  const CardImageSource.asset(String value)
    : this._(assetPath: value, networkUrl: null);

  const CardImageSource.network(String value)
    : this._(assetPath: null, networkUrl: value);

  const CardImageSource.none() : this._(assetPath: null, networkUrl: null);

  final String? assetPath;
  final String? networkUrl;

  bool get hasAsset => assetPath != null && assetPath!.isNotEmpty;

  bool get hasNetwork => networkUrl != null && networkUrl!.isNotEmpty;
}

const String _bundledCardImagesPrefix = 'assets/images/';
const Set<String> _supportedImageExtensions = <String>{
  'png',
  'jpg',
  'jpeg',
  'webp',
  'gif',
};

Future<Map<String, String>>? _bundledImageLookupFuture;

Future<Map<String, String>> _bundledImageLookup() {
  _bundledImageLookupFuture ??= _loadBundledImageLookup();
  return _bundledImageLookupFuture!;
}

Future<Map<String, String>> _loadBundledImageLookup() async {
  try {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      rootBundle,
    );
    final List<String> assets = manifest.listAssets();
    final Map<String, String> lookup = <String, String>{};
    for (final String path in assets) {
      if (!path.startsWith(_bundledCardImagesPrefix)) {
        continue;
      }
      final int slashIdx = path.lastIndexOf('/');
      final String fileName = slashIdx >= 0 ? path.substring(slashIdx + 1) : path;
      final int dotIdx = fileName.lastIndexOf('.');
      if (dotIdx <= 0 || dotIdx >= fileName.length - 1) {
        continue;
      }
      final String ext = fileName.substring(dotIdx + 1).toLowerCase();
      if (!_supportedImageExtensions.contains(ext)) {
        continue;
      }
      final String withoutExt = fileName.substring(0, dotIdx);
      final String key = withoutExt.trim().toLowerCase();
      if (key.isEmpty || lookup.containsKey(key)) {
        continue;
      }
      lookup[key] = path;
    }
    return lookup;
  } on Object {
    return <String, String>{};
  }
}

String _normalizeCardName(String value) {
  return value.trim().toLowerCase();
}

List<String> _nameVariants(String raw) {
  final String normalized = _normalizeCardName(raw);
  if (normalized.isEmpty) {
    return const <String>[];
  }
  final Set<String> variants = <String>{normalized};
  final String spacesCollapsed = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  variants.add(spacesCollapsed);
  variants.add(spacesCollapsed.replaceAll(' ', '_'));
  variants.add(spacesCollapsed.replaceAll(' ', '-'));
  variants.add(spacesCollapsed.replaceAll('_', ' '));
  variants.add(spacesCollapsed.replaceAll('-', ' '));
  variants.removeWhere((String value) => value.isEmpty);
  return variants.toList(growable: false);
}

Future<String?> bundledCardImageAssetPathForDisplayName(
  String displayName, {
  bool isOnyxTier = false,
}) async {
  final String trimmed = displayName.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final Map<String, String> lookup = await _bundledImageLookup();
  final String wikiBase = WikiImageUrlService.wikiFileStemFromDisplayName(
    trimmed,
    useOnyxArt: isOnyxTier,
  );
  // Onyx cards often share [displayName] with the non-Onyx catalog entry. The
  // merged candidate list would try base stems (e.g. `superhero`) before
  // `superhero_(onyx)` and incorrectly return bundled non-Onyx art — skip base
  // name variants and only match files named like the wiki Onyx stem.
  final List<String> candidates;
  if (isOnyxTier) {
    candidates = _nameVariants(wikiBase);
  } else {
    final Set<String> candidateSet = <String>{
      ..._nameVariants(trimmed),
      ..._nameVariants(wikiBase),
    };
    candidates = candidateSet.toList(growable: false);
  }
  for (final String key in candidates) {
    final String? assetPath = lookup[key];
    if (assetPath != null) {
      return assetPath;
    }
  }
  return null;
}

Future<bool> hasBundledCardImageForDisplayName(
  String displayName, {
  bool isOnyxTier = false,
}) async {
  final String? path = await bundledCardImageAssetPathForDisplayName(
    displayName,
    isOnyxTier: isOnyxTier,
  );
  return path != null && path.isNotEmpty;
}

Future<CardImageSource> resolveCardImageSource({
  required String displayName,
  required bool isOnyxTier,
  required String? networkUrl,
  required bool allowNetworkFetch,
}) async {
  final String? assetPath = await bundledCardImageAssetPathForDisplayName(
    displayName,
    isOnyxTier: isOnyxTier,
  );
  if (assetPath != null && assetPath.isNotEmpty) {
    return CardImageSource.asset(assetPath);
  }
  if (allowNetworkFetch && networkUrl != null && networkUrl.isNotEmpty) {
    return CardImageSource.network(networkUrl);
  }
  return const CardImageSource.none();
}

/// Pack art in [assets/images/shop_packs/]: prefer [scheduleImageFile] (`2026_06_29_accursed.png` from rotation JSON), else [selectorFile] (wiki selector name). Optional wiki URL when [allowNetworkFetch] is true.
///
/// Bundled files follow `shop_pack_<wikiSlug>.png` while JSON may reference dated
/// schedule names or `*_Pack_Selector.png` wiki filenames — [bundledShopPackImageAssetPath]
/// maps those to the same manifest keys as [Image.asset]. Shop UI uses bundled art only.
Future<CardImageSource> resolveShopPackImageSource({
  String? scheduleImageFile,
  required String selectorFile,
  required String wikiImageUrl,
  required bool allowNetworkFetch,
}) async {
  final String? sched = scheduleImageFile?.trim();
  if (sched != null && sched.isNotEmpty) {
    final String? a = await bundledShopPackImageAssetPath(sched);
    if (a != null && a.isNotEmpty) {
      return CardImageSource.asset(a);
    }
  }
  final String sel = selectorFile.trim();
  if (sel.isNotEmpty) {
    final String? b = await bundledShopPackImageAssetPath(sel);
    if (b != null && b.isNotEmpty) {
      return CardImageSource.asset(b);
    }
  }
  final String net = wikiImageUrl.trim();
  if (allowNetworkFetch && net.isNotEmpty) {
    return CardImageSource.network(net);
  }
  return const CardImageSource.none();
}

/// Keys used in [AssetManifest] for files under [assets/images/shop_packs/] are the
/// full filename stem lowercased (e.g. `shop_pack_accursed`). [imageFile] from JSON
/// is often `2026_06_29_accursed.png` or `Accursed_Pack_Selector.png` instead.
List<String> _shopPackManifestKeyCandidates(String imageFile) {
  final String trimmed = imageFile.trim();
  if (trimmed.isEmpty) {
    return const <String>[];
  }
  final int dotIdx = trimmed.lastIndexOf('.');
  final String base = dotIdx > 0 ? trimmed.substring(0, dotIdx) : trimmed;
  final String lower = base.trim().toLowerCase();
  final List<String> keys = <String>[];
  final Set<String> seen = <String>{};

  void addKey(String value) {
    final String k = value.trim().toLowerCase();
    if (k.isEmpty || seen.contains(k)) {
      return;
    }
    seen.add(k);
    keys.add(k);
  }

  addKey(lower);

  final RegExp dated = RegExp(r'^\d{4}_\d{2}_\d{2}_(.+)$');
  final Match? datedMatch = dated.firstMatch(lower);
  if (datedMatch != null) {
    addKey('shop_pack_${datedMatch.group(1)!}');
  }

  final RegExp wikiSelector = RegExp(r'^(.+)_pack_selector$');
  final Match? selMatch = wikiSelector.firstMatch(lower);
  if (selMatch != null) {
    addKey('shop_pack_${selMatch.group(1)!}');
  }

  return keys;
}

Future<String?> bundledShopPackImageAssetPath(String imageFile) async {
  final String trimmed = imageFile.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final Map<String, String> lookup = await _bundledImageLookup();
  for (final String key in _shopPackManifestKeyCandidates(trimmed)) {
    final String? path = lookup[key];
    if (path == null || path.isEmpty) {
      continue;
    }
    if (!path.startsWith('assets/images/shop_packs/')) {
      continue;
    }
    return path;
  }
  return null;
}

Future<bool> hasBundledShopPackImageAsset(String imageFile) async {
  final String? path = await bundledShopPackImageAssetPath(imageFile);
  return path != null && path.isNotEmpty;
}
