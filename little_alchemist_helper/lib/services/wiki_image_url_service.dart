import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Resolves preview URLs via the Fandom MediaWiki API (`File:{DisplayName}.png`).
/// Onyx-tier cards use `File:{Base}_(Onyx).png` on the wiki.
/// In-memory cache plus optional disk persistence ([persistUrls]) after new API responses.
class WikiImageUrlService {
  WikiImageUrlService({
    http.Client? httpClient,
    Map<String, String?>? seededUrls,
    Future<void> Function(Map<String, String?>)? persistUrls,
  }) : _injected = httpClient,
       _persistUrls = persistUrls {
    if (seededUrls != null) {
      _cache.addAll(seededUrls);
    }
  }

  final http.Client? _injected;
  final Future<void> Function(Map<String, String?>)? _persistUrls;
  http.Client? _lazyClient;

  http.Client _client() {
    return _injected ?? (_lazyClient ??= http.Client());
  }

  static const String _endpoint = 'https://lil-alchemist.fandom.com/api.php';

  /// Pause between consecutive wiki API calls (first call in the chain is immediate).
  static const Duration _delayBetweenWikiRequests = Duration(seconds: 1);

  /// Serializes all wiki HTTP work on this service; one in-flight request at a time.
  Future<void> _wikiRequestTail = Future<void>.value();

  int _wikiScheduledRequestCount = 0;

  Future<T> _runInWikiQueue<T>(Future<T> Function() action) {
    final Completer<T> completer = Completer<T>();
    _wikiRequestTail = _wikiRequestTail.then((_) async {
      if (_wikiScheduledRequestCount > 0) {
        await Future<void>.delayed(_delayBetweenWikiRequests);
      }
      _wikiScheduledRequestCount++;
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  /// Suffix for cache keys of onyx wiki files (same display name, different file on wiki).
  static const String onyxWikiCacheKeySuffix = '\u001Elah_onyx';

  /// Card names where `File:{DisplayName}.png` on the wiki does not point to card artwork.
  static const Map<String, String> _fixedWikiImageUrlsByDisplayName =
      <String, String>{
        'Portal':
            'https://static.wikia.nocookie.net/lil-alchemist/images/f/f0/Portal_%28Card%29.png/revision/latest?cb=20240917192322',
      };

  final Map<String, String?> _cache = <String, String?>{};

  static String? _fixedWikiImageUrlFor(String trimmedDisplayName) {
    return _fixedWikiImageUrlsByDisplayName[trimmedDisplayName];
  }

  /// Whether [cacheKey] was produced by [cacheKeyForWikiImage] with onyx art.
  static bool isOnyxWikiCacheKey(String cacheKey) {
    return cacheKey.endsWith(onyxWikiCacheKeySuffix);
  }

  /// Display name part of a wiki image cache key (strip [onyxWikiCacheKeySuffix] if present).
  static String displayNameFromWikiCacheKey(String cacheKey) {
    if (isOnyxWikiCacheKey(cacheKey)) {
      return cacheKey
          .substring(0, cacheKey.length - onyxWikiCacheKeySuffix.length)
          .trim();
    }
    return cacheKey.trim();
  }

  /// Stable key for [_cache] / persisted map: same [displayName] yields different keys for onyx vs base art.
  static String cacheKeyForWikiImage(
    String displayName, {
    required bool isOnyxTier,
  }) {
    final String t = displayName.trim();
    if (!isOnyxTier) {
      return t;
    }
    return '$t$onyxWikiCacheKeySuffix';
  }

  /// Wiki file stem (without `File:` / `.png`) for API and bundled asset candidates.
  static String wikiFileStemFromDisplayName(
    String displayName, {
    required bool useOnyxArt,
  }) {
    final String base = _wikiBaseNameFromDisplayName(displayName);
    if (base.isEmpty) {
      return base;
    }
    if (useOnyxArt) {
      return '${base}_(Onyx)';
    }
    return base;
  }

  /// Back-compat: stem for the default (non-onyx) wiki file. Prefer [wikiFileStemFromDisplayName].
  static String wikiFileTitleBaseFromDisplayName(String displayName) {
    return wikiFileStemFromDisplayName(displayName, useOnyxArt: false);
  }

  /// Safe filename stem for export (handles legacy plain keys and new onyx keys).
  static String wikiFileStemFromWikiImageCacheKey(String cacheKey) {
    final bool onyx = isOnyxWikiCacheKey(cacheKey);
    final String display = displayNameFromWikiCacheKey(cacheKey);
    return wikiFileStemFromDisplayName(display, useOnyxArt: onyx);
  }

  static String _wikiBaseNameFromDisplayName(String displayName) {
    String s = displayName.trim();
    if (s.isEmpty) {
      return s;
    }
    if (s.length > 6 && s.substring(0, 6).toLowerCase() == 'fused ') {
      s = s.substring(6).trim();
    }
    const String ruOnyx = ' · оникс';
    if (s.endsWith(ruOnyx)) {
      s = s.substring(0, s.length - ruOnyx.length).trim();
    }
    const String enOnyxDot = ' · Onyx';
    if (s.length >= enOnyxDot.length &&
        s.substring(s.length - enOnyxDot.length).toLowerCase() ==
            enOnyxDot.toLowerCase()) {
      s = s.substring(0, s.length - enOnyxDot.length).trim();
    }
    const String enOnyxParen = ' (Onyx)';
    if (s.endsWith(enOnyxParen)) {
      s = s.substring(0, s.length - enOnyxParen.length).trim();
    }
    return s;
  }

  /// Already known URL (memory or startup disk cache) with no network request.
  String? cachedUrlForDisplayName(
    String displayName, {
    bool isOnyxTier = false,
  }) {
    final String key = displayName.trim();
    if (key.isEmpty) {
      return null;
    }
    if (!isOnyxTier) {
      final String? fixed = _fixedWikiImageUrlFor(key);
      if (fixed != null) {
        return fixed;
      }
    }
    final String cacheKey = cacheKeyForWikiImage(key, isOnyxTier: isOnyxTier);
    final String? direct = _cache[cacheKey];
    if (direct != null) {
      return direct;
    }
    final String stem = wikiFileStemFromDisplayName(
      key,
      useOnyxArt: isOnyxTier,
    );
    if (stem != key) {
      final String? byStem = _cache[stem];
      if (byStem != null) {
        return byStem;
      }
    }
    if (!isOnyxTier) {
      final String norm = wikiFileStemFromDisplayName(key, useOnyxArt: false);
      if (norm != key) {
        return _cache[norm];
      }
    }
    return null;
  }

  Future<void> _persistIfNeeded() async {
    final Future<void> Function(Map<String, String?>)? p = _persistUrls;
    if (p == null) {
      return;
    }
    await p(Map<String, String?>.from(_cache));
  }

  /// Returns a direct image URL or null when the file does not exist on the wiki.
  Future<String?> resolveForDisplayName(
    String displayName, {
    bool isOnyxTier = false,
  }) async {
    final String key = displayName.trim();
    if (key.isEmpty) {
      return null;
    }
    if (!isOnyxTier) {
      final String? fixed = _fixedWikiImageUrlFor(key);
      if (fixed != null) {
        _cache[cacheKeyForWikiImage(key, isOnyxTier: false)] = fixed;
        return fixed;
      }
    }
    final String cacheKey = cacheKeyForWikiImage(key, isOnyxTier: isOnyxTier);
    final String? cachedByKey = _cache[cacheKey];
    if (cachedByKey != null) {
      return cachedByKey;
    }
    final String wikiStem = wikiFileStemFromDisplayName(
      key,
      useOnyxArt: isOnyxTier,
    );
    final String? cachedByStem = _cache[wikiStem];
    if (cachedByStem != null) {
      _cache[cacheKey] = cachedByStem;
      await _persistIfNeeded();
      return cachedByStem;
    }
    final String? url = await _fetchOne(wikiStem);
    _cache[wikiStem] = url;
    _cache[cacheKey] = url;
    await _persistIfNeeded();
    return url;
  }

  Future<void> resolveBatch(
    List<({String displayName, bool isOnyxTier})> requests,
  ) async {
    final Set<String> toFetchWiki = <String>{};

    for (final ({String displayName, bool isOnyxTier}) r in requests) {
      final String key = r.displayName.trim();
      if (key.isEmpty) {
        continue;
      }
      if (!r.isOnyxTier) {
        final String? fixedBatch = _fixedWikiImageUrlFor(key);
        if (fixedBatch != null) {
          _cache[cacheKeyForWikiImage(key, isOnyxTier: false)] = fixedBatch;
          continue;
        }
      }
      final String cacheKey = cacheKeyForWikiImage(
        key,
        isOnyxTier: r.isOnyxTier,
      );
      if (_cache[cacheKey] != null) {
        continue;
      }
      final String wikiStem = wikiFileStemFromDisplayName(
        key,
        useOnyxArt: r.isOnyxTier,
      );
      final String? stemHit = _cache[wikiStem];
      if (stemHit != null) {
        _cache[cacheKey] = stemHit;
        continue;
      }
      toFetchWiki.add(wikiStem);
    }

    final List<String> fetchList = toFetchWiki.toList();
    for (final String stem in fetchList) {
      final Map<String, String?> part = await _runInWikiQueue(
        () => _fetchBatch(<String>[stem]),
      );
      part.forEach((String k, String? v) {
        _cache[k] = v;
      });
    }

    for (final ({String displayName, bool isOnyxTier}) r in requests) {
      final String key = r.displayName.trim();
      if (key.isEmpty) {
        continue;
      }
      final String cacheKey = cacheKeyForWikiImage(
        key,
        isOnyxTier: r.isOnyxTier,
      );
      final String wikiStem = wikiFileStemFromDisplayName(
        key,
        useOnyxArt: r.isOnyxTier,
      );
      final String? u = _cache[cacheKey] ?? _cache[wikiStem];
      _cache[cacheKey] = u;
      _cache[wikiStem] = u;
    }

    if (fetchList.isNotEmpty) {
      await _persistIfNeeded();
    }
  }

  Future<String?> _fetchOne(String wikiStem) async {
    final Map<String, String?> batch = await _runInWikiQueue(
      () => _fetchBatch(<String>[wikiStem]),
    );
    return batch[wikiStem];
  }

  Future<Map<String, String?>> _fetchBatch(List<String> names) async {
    final StringBuffer titles = StringBuffer();
    for (int i = 0; i < names.length; i++) {
      if (i > 0) {
        titles.write('|');
      }
      titles.write(Uri.encodeComponent('File:${names[i]}.png'));
    }
    final Uri uri = Uri.parse(
      '$_endpoint?action=query&prop=imageinfo&iiprop=url&format=json&titles=${titles.toString()}',
    );
    final http.Response res = await _client().get(uri);
    if (res.statusCode != 200) {
      return <String, String?>{for (final String n in names) n: null};
    }
    final Object? decoded = jsonDecode(res.body);
    if (decoded is! Map<String, Object?>) {
      return <String, String?>{for (final String n in names) n: null};
    }
    final Object? query = decoded['query'];
    if (query is! Map<String, Object?>) {
      return <String, String?>{for (final String n in names) n: null};
    }
    final Object? pages = query['pages'];
    if (pages is! Map<String, Object?>) {
      return <String, String?>{for (final String n in names) n: null};
    }
    final Map<String, String?> byTitle = <String, String?>{};
    for (final Object? pageEntry in pages.values) {
      if (pageEntry is! Map<String, Object?>) {
        continue;
      }
      final Object? title = pageEntry['title'];
      if (title is! String) {
        continue;
      }
      String? url;
      final Object? missing = pageEntry['missing'];
      if (missing == null || missing == '') {
        final Object? ii = pageEntry['imageinfo'];
        if (ii is List && ii.isNotEmpty) {
          final Object? first = ii.first;
          if (first is Map<String, Object?>) {
            final Object? u = first['url'];
            if (u is String) {
              url = u;
            }
          }
        }
      }
      if (title.startsWith('File:') && title.endsWith('.png')) {
        final String display = title.substring(
          'File:'.length,
          title.length - '.png'.length,
        );
        byTitle[display] = url;
        // MediaWiki treats underscores and spaces as equivalent; the API returns
        // canonical titles with spaces (e.g. `Wealth (Onyx)`) while we request
        // stems with underscores (`Wealth_(Onyx)`). Alias so batch lookup hits.
        final String underscoreStem = display.replaceAll(' ', '_');
        if (underscoreStem != display) {
          byTitle[underscoreStem] = url;
        }
      }
    }
    return <String, String?>{
      for (final String n in names) n: _resolveWikiUrlFromByTitle(byTitle, n),
    };
  }

  /// [wikiFileStemFromDisplayName] uses spaces in multi-word names (e.g. `Fairy Tale_(Onyx)`).
  /// The API may normalize to `File:Fairy Tale (Onyx).png`; we then index as `Fairy_Tale_(Onyx)`,
  /// so the requested [stem] must be matched with space/underscore variants.
  static String? _resolveWikiUrlFromByTitle(
    Map<String, String?> byTitle,
    String stem,
  ) {
    final String? direct = byTitle[stem];
    if (direct != null) {
      return direct;
    }
    final String spacesToUnderscores = stem.replaceAll(' ', '_');
    if (spacesToUnderscores != stem) {
      final String? u = byTitle[spacesToUnderscores];
      if (u != null) {
        return u;
      }
    }
    final String underscoreBeforeParen = stem.replaceAllMapped(
      RegExp(r'_\('),
      (Match m) => ' (',
    );
    if (underscoreBeforeParen != stem) {
      final String? u = byTitle[underscoreBeforeParen];
      if (u != null) {
        return u;
      }
    }
    return null;
  }

  void dispose() {
    _injected?.close();
    _lazyClient?.close();
    _lazyClient = null;
  }
}
