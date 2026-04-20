import 'package:flutter/material.dart';

import '../../l10n/l10n_ext.dart';

/// Outlined control aligned with [DropdownButtonFormField] / [CardSortSelector].
class DuplicateGroupingCheckbox extends StatelessWidget {
  const DuplicateGroupingCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodyLarge;
    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
      child: Row(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.collectionCollapseDuplicates,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            height: 44,
            child: Checkbox(
            value: value,
            onChanged: (bool? next) {
              if (next != null) {
                onChanged(next);
              }
            },
          ),
          )
        ],
      ),
    );
  }
}
