// Generates assets/data/shop_packs.json and assets/data/pack_schedule_occasions.json
// from pack_schedule_source.txt
// Run from project root: dart run tool/build_shop_packs_json.dart
//
// Tags in parentheses: `:occ:` → JSON `occasion` (shown as Onyx on the shop screen),
// `:gcc:` → JSON `gcc` (shown as Gold).
// Unique `:occ:` values are also written to pack_schedule_occasions.json (fallback
// if `onyx_wiki_display_names.json` fails to parse; primary allowlist is wiki category).

import 'dart:convert';
import 'dart:io';

void main() {
  final File source = File('tool/pack_schedule_source.txt');
  final List<String> lines = source.readAsLinesSync();
  String? section;
  final List<Map<String, Object?>> packs = <Map<String, Object?>>[];
  final Set<String> uniqueOccasions = <String>{};
  final RegExp packLine = RegExp(
    r'^(.+?)\s*-\s*(\d{1,2})/(\d{1,2})/(\d{2})\s*\(',
  );
  for (final String raw in lines) {
    final String line = raw.trim();
    if (line.isEmpty) {
      continue;
    }
    final RegExpMatch? m = packLine.firstMatch(line);
    if (m == null) {
      section = line;
      continue;
    }
    final String name = m.group(1)!.trim();
    final int month = int.parse(m.group(2)!);
    final int day = int.parse(m.group(3)!);
    int year = int.parse(m.group(4)!);
    if (year < 100) {
      year += 2000;
    }
    final String y = year.toString().padLeft(4, '0');
    final String mo = month.toString().padLeft(2, '0');
    final String d = day.toString().padLeft(2, '0');
    final String id = '${y}_${mo}_${d}_${_slug(name)}';
    final String close = line.contains(')')
        ? line.substring(line.indexOf('('))
        : '';
    final String occ = _extractOcc(close);
    final String gcc = _extractGcc(close);
    if (occ.isNotEmpty) {
      uniqueOccasions.add(occ);
    }
    final String imageFile = '$id.png';
    packs.add(<String, Object?>{
      'id': id,
      'displayName': name,
      'shopStart': '$y-$mo-$d',
      'section': section ?? '',
      'occasion': occ,
      'gcc': gcc,
      'imageFile': imageFile,
    });
  }
  final Map<String, Object> root = <String, Object>{
    'shopVisibleDays': 4,
    'packs': packs,
  };
  final File out = File('assets/data/shop_packs.json');
  out.createSync(recursive: true);
  out.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(root),
  );
  stdout.writeln('Wrote ${packs.length} packs to ${out.path}');

  final List<String> sortedOcc = uniqueOccasions.toList()..sort();
  final File occOut = File('assets/data/pack_schedule_occasions.json');
  occOut.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(<String, Object>{
      'occasions': sortedOcc,
    }),
  );
  stdout.writeln(
    'Wrote ${sortedOcc.length} unique :occ: strings to ${occOut.path}',
  );
}

String _slug(String name) {
  final String lower = name.toLowerCase().trim();
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < lower.length; i++) {
    final int c = lower.codeUnitAt(i);
    final bool alnum = (c >= 48 && c <= 57) || (c >= 97 && c <= 122);
    if (alnum) {
      b.writeCharCode(c);
    } else if (c == 32 || c == 45 || c == 39) {
      b.write('_');
    }
  }
  String s = b.toString().replaceAll(RegExp('_+'), '_');
  if (s.isEmpty) {
    return 'pack';
  }
  return s;
}

String _extractOcc(String insideParens) {
  final RegExp r = RegExp(r':occ:([^/]+?)(?=\s*/\s*(:gcc:|Hybrid|\)))');
  final RegExpMatch? m = r.firstMatch(insideParens);
  if (m == null) {
    return '';
  }
  return m.group(1)!.trim();
}

String _extractGcc(String insideParens) {
  final RegExp r1 = RegExp(r':gcc:([^/]+?)(?=\s*/\s*|\s*\))');
  final RegExpMatch? m1 = r1.firstMatch(insideParens);
  if (m1 != null) {
    return m1.group(1)!.trim();
  }
  final RegExp r1b = RegExp(r':gcc:([^)]+)');
  final RegExpMatch? m1b = r1b.firstMatch(insideParens);
  if (m1b != null) {
    return m1b.group(1)!.trim();
  }
  final RegExp r2 = RegExp(r'/\s*Hybrid Combo\s*\)');
  if (r2.hasMatch(insideParens)) {
    return 'Hybrid Combo';
  }
  return '';
}
