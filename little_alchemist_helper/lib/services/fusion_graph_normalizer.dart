import '../models/alchemy_card.dart';

/// Builds reverse edges: if [A][B]=R, ensures [B][A]=R.
///
/// On conflict (different results), preserves the existing value at [B][A].
Map<String, AlchemyCard> normalizeUndirectedFusionGraph(
  Map<String, AlchemyCard> catalog,
) {
  final Map<String, Map<String, String>> edges =
      <String, Map<String, String>>{};
  for (final MapEntry<String, AlchemyCard> e in catalog.entries) {
    edges[e.key] = Map<String, String>.from(e.value.combinations);
  }
  for (final MapEntry<String, AlchemyCard> e in catalog.entries) {
    final String a = e.key;
    for (final MapEntry<String, String> ce in e.value.combinations.entries) {
      final String b = ce.key;
      final String r = ce.value;
      if (!catalog.containsKey(b)) {
        continue;
      }
      final Map<String, String> atB = edges[b]!;
      final String? existing = atB[a];
      if (existing != null && existing != r) {
        assert(() {
          throw StateError(
            'Конфликт слияния: $a + $b → $r, но $b + $a → $existing',
          );
        }());
        continue;
      }
      atB[a] = r;
    }
  }
  return <String, AlchemyCard>{
    for (final MapEntry<String, AlchemyCard> e in catalog.entries)
      e.key: e.value.copyWith(combinations: edges[e.key]!),
  };
}
