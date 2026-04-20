// Пересобирает assets/data/onyx_wiki_display_names.json из Category:Onyx (MediaWiki API).
// Запуск из корня: dart run tool/fetch_onyx_wiki_display_names.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String _apiUrl =
    'https://lil-alchemist.fandom.com/api.php?action=query&list=categorymembers&cmtitle=Category:Onyx&cmlimit=500&format=json';

Future<void> main() async {
  final http.Response r = await http.get(
    Uri.parse(_apiUrl),
    headers: <String, String>{
      'User-Agent': 'LittleAlchemistHelper/1.0 (onyx list sync)',
    },
  );
  if (r.statusCode != 200) {
    stderr.writeln('HTTP ${r.statusCode}');
    exitCode = 1;
    return;
  }
  final Object? decoded = jsonDecode(r.body);
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('Unexpected JSON root');
    exitCode = 1;
    return;
  }
  final Object? queryRaw = decoded['query'];
  if (queryRaw is! Map<String, dynamic>) {
    stderr.writeln('Missing query');
    exitCode = 1;
    return;
  }
  final Object? cmRaw = queryRaw['categorymembers'];
  if (cmRaw is! List<dynamic>) {
    stderr.writeln('Missing categorymembers');
    exitCode = 1;
    return;
  }
  const String suffix = ' (Onyx)';
  final List<String> names = <String>[];
  for (final Object? e in cmRaw) {
    if (e is! Map<String, dynamic>) {
      continue;
    }
    final Object? titleRaw = e['title'];
    if (titleRaw is! String) {
      continue;
    }
    final String t = titleRaw;
    if (!t.endsWith(suffix)) {
      stderr.writeln('Skip unexpected title: $t');
      continue;
    }
    names.add(t.substring(0, t.length - suffix.length));
  }
  names.sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  final Map<String, Object> out = <String, Object>{
    'sourceWikiUrl': 'https://lil-alchemist.fandom.com/wiki/Category:Onyx',
    'generatedAtUtc': DateTime.now().toUtc().toIso8601String().split('T').first,
    'displayNames': names,
  };
  const String path = 'assets/data/onyx_wiki_display_names.json';
  final File f = File(path);
  await f.writeAsString(
    const JsonEncoder.withIndent('  ').convert(out),
  );
  stdout.writeln('Wrote ${names.length} names to $path');
}
