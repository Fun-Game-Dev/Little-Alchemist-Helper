import 'package:flutter/material.dart';

import '../../l10n/l10n_ext.dart';
import '../../util/card_sort.dart';

class CardSortSelector extends StatelessWidget {
  const CardSortSelector({
    super.key,
    required this.mode,
    required this.direction,
    required this.onModeChanged,
    required this.onDirectionChanged,
    this.modes = CardListSortMode.values,
    this.decoration,
  });

  final CardListSortMode mode;
  final CardListSortDirection direction;
  final ValueChanged<CardListSortMode> onModeChanged;
  final ValueChanged<CardListSortDirection> onDirectionChanged;
  final List<CardListSortMode> modes;
  final InputDecoration? decoration;

  String _optionLabel(
    BuildContext context,
    CardListSortMode currentMode,
    CardListSortDirection currentDirection,
  ) {
    final String arrow = currentDirection == CardListSortDirection.ascending
        ? '↑'
        : '↓';
    return '${localizedSortModeLabel(context.l10n, currentMode)} $arrow';
  }

  @override
  Widget build(BuildContext context) {
    final _SortVariant selected = _SortVariant(
      mode: mode,
      direction: direction,
    );
    final List<_SortVariant> variants = <_SortVariant>[
      for (final CardListSortMode currentMode in modes) ...<_SortVariant>[
        _SortVariant(
          mode: currentMode,
          direction: CardListSortDirection.ascending,
        ),
        _SortVariant(
          mode: currentMode,
          direction: CardListSortDirection.descending,
        ),
      ],
    ];
    return DropdownButtonFormField<_SortVariant>(
      value: selected,
      isExpanded: true,
      decoration:
          decoration ??
          InputDecoration(
            labelText: context.l10n.labelSort,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
          ),
      items: variants.map((_SortVariant variant) {
        return DropdownMenuItem<_SortVariant>(
          value: variant,
          child: Text(
            _optionLabel(context, variant.mode, variant.direction),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (_SortVariant? value) {
        if (value == null) {
          return;
        }
        if (value.mode != mode) {
          onModeChanged(value.mode);
        }
        if (value.direction != direction) {
          onDirectionChanged(value.direction);
        }
      },
      selectedItemBuilder: (BuildContext context) {
        return variants.map((_SortVariant variant) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _optionLabel(context, variant.mode, variant.direction),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
    );
  }
}

class _SortVariant {
  const _SortVariant({required this.mode, required this.direction});

  final CardListSortMode mode;
  final CardListSortDirection direction;

  @override
  bool operator ==(Object other) {
    return other is _SortVariant &&
        other.mode == mode &&
        other.direction == direction;
  }

  @override
  int get hashCode => Object.hash(mode, direction);
}
