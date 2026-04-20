// Fetches Special Packs list from wiki (MediaWiki API) and writes assets/data/special_packs.json
// Run: dart run tool/build_special_packs_json.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String _api =
    'https://lil-alchemist.fandom.com/api.php?action=parse&page=Special_Packs&prop=text&format=json';

/// Strips Fandom thumbnail path so full-resolution URL is cached like card art.
String normalizeWikiPackImageUrl(String raw) {
  String u = raw.trim();
  if (u.isEmpty) {
    return u;
  }
  u = u.replaceAll(
    '/revision/latest/scale-to-width-down/130',
    '/revision/latest',
  );
  u = u.replaceAll(
    '/revision/latest/scale-to-width-down/180',
    '/revision/latest',
  );
  return u;
}

void main() async {
  final http.Client client = http.Client();
  try {
    final http.Response res = await client.get(Uri.parse(_api));
    if (res.statusCode != 200) {
      stderr.writeln('HTTP ${res.statusCode}');
      exitCode = 1;
      return;
    }
    final Object? decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('Bad JSON');
      exitCode = 1;
      return;
    }
    final Object? parse = decoded['parse'];
    if (parse is! Map<String, dynamic>) {
      stderr.writeln('No parse');
      exitCode = 1;
      return;
    }
    final Object? text = parse['text'];
    if (text is! Map<String, dynamic>) {
      stderr.writeln('No text');
      exitCode = 1;
      return;
    }
    final Object? star = text['*'];
    if (star is! String) {
      stderr.writeln('No html');
      exitCode = 1;
      return;
    }
    final String html = star;
    final List<({String section, String slug, String displayName, String? imageUrl, String? selectorFile})> rows =
        _parsePacks(html);
    final List<Map<String, Object?>> packs = <Map<String, Object?>>[];
    final Set<String> seenSlugs = <String>{};
    for (final ({String section, String slug, String displayName, String? imageUrl, String? selectorFile}) r in rows) {
      if (seenSlugs.contains(r.slug)) {
        continue;
      }
      seenSlugs.add(r.slug);
      packs.add(<String, Object?>{
        'wikiSlug': r.slug,
        'displayName': r.displayName,
        'section': r.section,
        if (r.selectorFile != null) 'selectorFile': r.selectorFile,
        if (r.imageUrl != null && r.imageUrl!.isNotEmpty)
          'wikiImageUrl': normalizeWikiPackImageUrl(r.imageUrl!),
      });
    }
    final Map<String, Object> root = <String, Object>{
      'wikiListUrl': 'https://lil-alchemist.fandom.com/wiki/Special_Packs',
      'packs': packs,
    };
    final File out = File('assets/data/special_packs.json');
    out.createSync(recursive: true);
    out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(root));
    stdout.writeln('Wrote ${packs.length} packs to ${out.path}');
  } finally {
    client.close();
  }
}

List<({String section, String slug, String displayName, String? imageUrl, String? selectorFile})> _parsePacks(
  String html,
) {
  final List<({String section, String slug, String displayName, String? imageUrl, String? selectorFile})> out =
      <({String section, String slug, String displayName, String? imageUrl, String? selectorFile})>[];

  final List<_Slice> slices = _sliceBySection(html);
  for (final _Slice sl in slices) {
    final String section = sl.section;
    final Iterable<RegExpMatch> anchors =
        RegExp(r'href="/wiki/Special_Packs/([^"]+)"').allMatches(sl.html);
    for (final RegExpMatch am in anchors) {
      final String slugRaw = am.group(1)!;
      final String slug = Uri.decodeComponent(slugRaw);
      final int start = am.start;
      int end = sl.html.indexOf('</a>', start);
      if (end < 0) {
        end = sl.html.length;
      }
      final String chunk = sl.html.substring(start, end);
      final ({String url, String? dataKey})? img = _wikiaImageInChunk(chunk);
      if (img == null) {
        continue;
      }
      final String url = img.url;
      final String? dataKey = img.dataKey;
      String displayName = '${_titleFromSlug(slug)} Pack';
      if (dataKey != null && dataKey.isNotEmpty) {
        final String dk = Uri.decodeComponent(dataKey).replaceAll('_', ' ');
        if (dk.toLowerCase().endsWith(' pack selector.png')) {
          displayName =
              '${dk.substring(0, dk.length - ' pack selector.png'.length).trim()} Pack';
        }
      }
      String? selectorFile;
      if (dataKey != null && dataKey.toLowerCase().endsWith('.png')) {
        selectorFile = Uri.decodeComponent(dataKey);
      }
      out.add((
        section: section,
        slug: slug,
        displayName: displayName,
        imageUrl: url,
        selectorFile: selectorFile,
      ));
    }
  }
  return out;
}

String _titleFromSlug(String slug) {
  return slug.replaceAll('_', ' ');
}

/// Splits wiki HTML by section headers (Brand New / Active / Seasonal / …).
class _Slice {
  const _Slice({required this.section, required this.html});

  final String section;
  final String html;
}

List<_Slice> _sliceBySection(String html) {
  final RegExp header = RegExp(
    r'<th[^>]*colspan="[56]"[^>]*>\s*([^<]+?)\s*<hr',
    caseSensitive: false,
  );
  final List<_Slice> slices = <_Slice>[];
  final Iterable<RegExpMatch> headers = header.allMatches(html);
  int start = 0;
  String currentSection = 'Special Packs';
  for (final RegExpMatch m in headers) {
    if (m.start > start) {
      slices.add(_Slice(section: currentSection, html: html.substring(start, m.start)));
    }
    final String raw = m.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim();
    currentSection = raw;
    start = m.end;
  }
  if (start < html.length) {
    slices.add(_Slice(section: currentSection, html: html.substring(start)));
  }
  if (slices.isEmpty) {
    slices.add(_Slice(section: currentSection, html: html));
  }
  return slices;
}

({String url, String? dataKey})? _wikiaImageInChunk(String chunk) {
  final RegExpMatch? keyM = RegExp(
    r'data-image-key="([^"]+)"',
    caseSensitive: false,
  ).firstMatch(chunk);
  final String? dataKey = keyM?.group(1);
  String? url = RegExp(
    r'data-src="(https://static\.wikia\.nocookie\.net/lil-alchemist/images/[^"]+)"',
    caseSensitive: false,
  ).firstMatch(chunk)?.group(1);
  url ??= RegExp(
    r'src="(https://static\.wikia\.nocookie\.net/lil-alchemist/images/[^"]+)"',
    caseSensitive: false,
  ).firstMatch(chunk)?.group(1);
  if (url == null || url.isEmpty) {
    return null;
  }
  return (url: url, dataKey: dataKey);
}
