// Downloads pack preview images from Lil' Alchemist Wiki (MediaWiki API).
// Run from project root: dart run tool/download_shop_pack_images.dart
//
// Tries `File:{Name} Pack.png` for each pack [displayName]. Saves to
// assets/images/shop_packs/ using [imageFile] from shop_packs.json.
// Skips download if the file already exists and is non-empty (delete to re-fetch).

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String _wikiApi = 'https://lil-alchemist.fandom.com/api.php';

Future<void> main() async {
  final File packsFile = File('assets/data/shop_packs.json');
  if (!packsFile.existsSync()) {
    stderr.writeln('Missing ${packsFile.path}. Run tool/build_shop_packs_json.dart first.');
    exitCode = 1;
    return;
  }
  final Directory outDir = Directory('assets/images/shop_packs');
  outDir.createSync(recursive: true);

  final Object? decoded = jsonDecode(packsFile.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('Invalid shop_packs.json');
    exitCode = 1;
    return;
  }
  final Object? packsRaw = decoded['packs'];
  if (packsRaw is! List<dynamic>) {
    stderr.writeln('shop_packs.json: packs must be array');
    exitCode = 1;
    return;
  }

  final http.Client client = http.Client();
  try {
    int ok = 0;
    int skipped = 0;
    int missing = 0;
    for (final Object? item in packsRaw) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final String? displayName = item['displayName'] as String?;
      final String? imageFile = item['imageFile'] as String?;
      if (displayName == null || imageFile == null || imageFile.isEmpty) {
        continue;
      }
      final File dest = File('assets/images/shop_packs/$imageFile');
      if (dest.existsSync() && dest.lengthSync() > 0) {
        skipped++;
        continue;
      }
      final String wikiTitle = '$displayName Pack';
      final String? url = await _wikiFileUrl(client, wikiTitle);
      if (url == null || url.isEmpty) {
        stdout.writeln('No wiki image: $wikiTitle');
        missing++;
        continue;
      }
      final http.Response img = await client.get(Uri.parse(url));
      if (img.statusCode != 200 || img.bodyBytes.isEmpty) {
        stdout.writeln('Download failed ($wikiTitle): HTTP ${img.statusCode}');
        missing++;
        continue;
      }
      dest.writeAsBytesSync(img.bodyBytes);
      stdout.writeln('Saved ${dest.path}');
      ok++;
    }
    stdout.writeln('Done. Downloaded: $ok, skipped (exists): $skipped, missing: $missing');
  } finally {
    client.close();
  }
}

Future<String?> _wikiFileUrl(http.Client client, String displayBaseName) async {
  final String title = Uri.encodeComponent('File:$displayBaseName.png');
  final Uri uri = Uri.parse(
    '$_wikiApi?action=query&prop=imageinfo&iiprop=url&format=json&titles=$title',
  );
  final http.Response res = await client.get(uri);
  if (res.statusCode != 200) {
    return null;
  }
  final Object? json = jsonDecode(res.body);
  if (json is! Map<String, dynamic>) {
    return null;
  }
  final Object? query = json['query'];
  if (query is! Map<String, dynamic>) {
    return null;
  }
  final Object? pages = query['pages'];
  if (pages is! Map<String, dynamic>) {
    return null;
  }
  for (final Object? pageEntry in pages.values) {
    if (pageEntry is! Map<String, dynamic>) {
      continue;
    }
    final Object? missing = pageEntry['missing'];
    if (missing != null && missing != '') {
      continue;
    }
    final Object? ii = pageEntry['imageinfo'];
    if (ii is List && ii.isNotEmpty) {
      final Object? first = ii.first;
      if (first is Map<String, dynamic>) {
        final Object? u = first['url'];
        if (u is String) {
          return u;
        }
      }
    }
  }
  return null;
}
