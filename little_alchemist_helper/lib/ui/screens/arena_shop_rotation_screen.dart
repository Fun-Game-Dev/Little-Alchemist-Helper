import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n_ext.dart';
import '../../services/arena_shop_rotation_service.dart';

class ArenaShopRotationScreen extends StatefulWidget {
  const ArenaShopRotationScreen({super.key});

  @override
  State<ArenaShopRotationScreen> createState() =>
      _ArenaShopRotationScreenState();
}

class _ArenaShopRotationScreenState extends State<ArenaShopRotationScreen> {
  static const ArenaShopRotationService _service = ArenaShopRotationService();

  Timer? _ticker;
  ArenaShopSnapshot _snapshot = _service.snapshotAt();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (Timer _) {
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = _service.snapshotAt();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatDurationLabel(Duration duration) {
    final int days = duration.inDays;
    if (days > 0) {
      return context.l10n.eventsDurationDays(days);
    }
    final int hours = duration.inHours;
    if (hours > 0) {
      return context.l10n.eventsDurationHours(hours);
    }
    final int minutes = duration.inMinutes;
    return context.l10n.eventsDurationMinutes(minutes.clamp(1, 59));
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat dateFormat = DateFormat.yMMMd(locale.toString());
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 24),
      itemCount: ArenaShopRotationService.abilities.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _CurrentArenaBanner(
            currentAbilityName: _snapshot.currentAbility.name,
            timeLeftLabel: _formatDurationLabel(_snapshot.timeUntilRotation),
          );
        }
        final ArenaAbilityEntry ability =
            ArenaShopRotationService.abilities[index - 1];
        final ArenaAbilityWindow window = _service.nextWindowForAbility(
          ability,
        );
        final bool isCurrent = identical(ability, _snapshot.currentAbility);
        return _ArenaAbilityCard(
          ability: ability,
          window: window,
          dateFormat: dateFormat,
          isCurrent: isCurrent,
          formatDurationLabel: _formatDurationLabel,
        );
      },
    );
  }
}

class _CurrentArenaBanner extends StatelessWidget {
  const _CurrentArenaBanner({
    required this.currentAbilityName,
    required this.timeLeftLabel,
  });

  final String currentAbilityName;
  final String timeLeftLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary, width: 1.4),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.shopping_bag, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.arenaCurrentInShop(currentAbilityName, timeLeftLabel),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaAbilityCard extends StatelessWidget {
  const _ArenaAbilityCard({
    required this.ability,
    required this.window,
    required this.dateFormat,
    required this.isCurrent,
    required this.formatDurationLabel,
  });

  final ArenaAbilityEntry ability;
  final ArenaAbilityWindow window;
  final DateFormat dateFormat;
  final bool isCurrent;
  final String Function(Duration duration) formatDurationLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                ability.iconAssetPath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      );
                    },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ability.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ability.alchemistType} - ${ability.shortDescription}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...ability.tiers.map(
                        (ArenaAbilityTier tier) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${tier.title}: ${tier.effect} | ${tier.cost}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        window.isActiveNow
                            ? context.l10n.arenaCurrentWindow(
                                formatDurationLabel(window.timeUntilEnd!),
                              )
                            : context.l10n.arenaNextWindow(
                                dateFormat.format(window.startUtc),
                                dateFormat.format(window.endUtc),
                                formatDurationLabel(window.timeUntilStart),
                              ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
