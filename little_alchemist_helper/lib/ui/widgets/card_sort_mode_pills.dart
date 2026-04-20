import 'package:flutter/material.dart';

import '../../l10n/l10n_ext.dart';
import '../../util/card_sort.dart';

/// Card-list sort mode selector (one active pill).
class CardSortModePills extends StatelessWidget {
  const CardSortModePills({
    super.key,
    required this.value,
    required this.onChanged,
    this.modes = const <CardListSortMode>[
      CardListSortMode.byName,
      CardListSortMode.byRarity,
      CardListSortMode.byPower,
    ],
  });

  final CardListSortMode value;
  final ValueChanged<CardListSortMode> onChanged;
  final List<CardListSortMode> modes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: modes.map((CardListSortMode m) {
        return ChoiceChip(
          label: Text(localizedSortModeLabel(context.l10n, m)),
          selected: value == m,
          onSelected: (bool selected) {
            if (selected) {
              onChanged(m);
            }
          },
        );
      }).toList(),
    );
  }
}
